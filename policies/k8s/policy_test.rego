package k8s_test

import rego.v1

import data.k8s

good_deployment := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {"name": "web", "namespace": "kiln-demo"},
	"spec": {"template": {"spec": {
		"serviceAccountName": "web",
		"automountServiceAccountToken": false,
		"securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
		"containers": [{
			"name": "web",
			"image": "registry.example/web@sha256:0000000000000000000000000000000000000000000000000000000000000000",
			"securityContext": {
				"runAsNonRoot": true,
				"readOnlyRootFilesystem": true,
				"allowPrivilegeEscalation": false,
				"capabilities": {"drop": ["ALL"]},
			},
			"resources": {"limits": {"cpu": "200m", "memory": "128Mi"}, "requests": {"cpu": "50m", "memory": "64Mi"}},
		}],
	}}},
}

container_patch(patch) := object.union(good_deployment, {"spec": {"template": {"spec": {"containers": [object.union(good_deployment.spec.template.spec.containers[0], patch)]}}}})

test_good_deployment_allowed if {
	count(k8s.deny) == 0 with input as good_deployment
}

test_root_container_denied if {
	bad := container_patch({"securityContext": {"runAsNonRoot": false, "readOnlyRootFilesystem": true, "allowPrivilegeEscalation": false, "capabilities": {"drop": ["ALL"]}}})
	some msg in k8s.deny with input as bad
	contains(msg, "runAsNonRoot")
}

test_writable_root_filesystem_denied if {
	bad := container_patch({"securityContext": {"runAsNonRoot": true, "readOnlyRootFilesystem": false, "allowPrivilegeEscalation": false, "capabilities": {"drop": ["ALL"]}}})
	some msg in k8s.deny with input as bad
	contains(msg, "readOnlyRootFilesystem")
}

test_privilege_escalation_denied if {
	bad := container_patch({"securityContext": {"runAsNonRoot": true, "readOnlyRootFilesystem": true, "allowPrivilegeEscalation": true, "capabilities": {"drop": ["ALL"]}}})
	some msg in k8s.deny with input as bad
	contains(msg, "allowPrivilegeEscalation")
}

test_missing_limits_denied if {
	no_limits := object.remove(good_deployment.spec.template.spec.containers[0], ["resources"])
	bad := json.patch(good_deployment, [{"op": "replace", "path": "/spec/template/spec/containers/0", "value": no_limits}])
	some msg in k8s.deny with input as bad
	contains(msg, "limits")
}

test_unpinned_image_denied if {
	bad := container_patch({"image": "nginx:latest"})
	some msg in k8s.deny with input as bad
	contains(msg, "digest")
}

test_namespace_without_restricted_label_denied if {
	ns := {"apiVersion": "v1", "kind": "Namespace", "metadata": {"name": "x", "labels": {"pod-security.kubernetes.io/enforce": "baseline"}}}
	some msg in k8s.deny with input as ns
	contains(msg, "restricted")
}

test_namespace_with_restricted_label_allowed if {
	ns := {"apiVersion": "v1", "kind": "Namespace", "metadata": {"name": "x", "labels": {"pod-security.kubernetes.io/enforce": "restricted"}}}
	count(k8s.deny) == 0 with input as ns
}

test_service_account_without_workload_identity_denied if {
	sa := {"apiVersion": "v1", "kind": "ServiceAccount", "metadata": {"name": "web", "namespace": "kiln-demo"}}
	some msg in k8s.deny with input as sa
	contains(msg, "iam.gke.io/gcp-service-account")
}

test_default_deny_policy_must_select_all_pods if {
	np := {"apiVersion": "networking.k8s.io/v1", "kind": "NetworkPolicy", "metadata": {"name": "default-deny", "namespace": "kiln-demo"}, "spec": {"podSelector": {"matchLabels": {"app": "web"}}, "policyTypes": ["Ingress", "Egress"]}}
	some msg in k8s.deny with input as np
	contains(msg, "default-deny")
}

test_host_network_denied if {
	bad := json.patch(good_deployment, [{"op": "add", "path": "/spec/template/spec/hostNetwork", "value": true}])
	some msg in k8s.deny with input as bad
	contains(msg, "host namespaces")
}

test_cronjob_root_container_denied if {
	pod := good_deployment.spec.template.spec
	root := json.patch(pod, [{"op": "replace", "path": "/containers/0/securityContext/runAsNonRoot", "value": false}, {"op": "replace", "path": "/securityContext/runAsNonRoot", "value": false}])
	cron := {"apiVersion": "batch/v1", "kind": "CronJob", "metadata": {"name": "nightly"}, "spec": {"jobTemplate": {"spec": {"template": {"spec": root}}}}}
	some msg in k8s.deny with input as cron
	contains(msg, "runAsNonRoot")
}

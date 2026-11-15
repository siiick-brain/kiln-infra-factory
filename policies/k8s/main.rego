# Conftest rules for the Kubernetes manifests in k8s/.
package k8s

import rego.v1

workload_kinds := {"Deployment", "StatefulSet", "DaemonSet", "Job", "ReplicaSet"}

pod_spec := input.spec.template.spec if input.kind in workload_kinds

pod_spec := input.spec if input.kind == "Pod"

pod_spec := input.spec.jobTemplate.spec.template.spec if input.kind == "CronJob"

containers contains c if {
	some c in pod_spec.containers
}

containers contains c if {
	some c in object.get(pod_spec, "initContainers", [])
}

name := object.get(input.metadata, "name", "unnamed")

run_as_non_root(c) if c.securityContext.runAsNonRoot == true

run_as_non_root(c) if {
	not c.securityContext.runAsNonRoot == false
	pod_spec.securityContext.runAsNonRoot == true
}

deny contains msg if {
	some c in containers
	not run_as_non_root(c)
	msg := sprintf("%s/%s container %s must set runAsNonRoot true", [input.kind, name, c.name])
}

deny contains msg if {
	some c in containers
	not c.securityContext.readOnlyRootFilesystem == true
	msg := sprintf("%s/%s container %s must set readOnlyRootFilesystem true", [input.kind, name, c.name])
}

deny contains msg if {
	some c in containers
	not c.securityContext.allowPrivilegeEscalation == false
	msg := sprintf("%s/%s container %s must set allowPrivilegeEscalation false", [input.kind, name, c.name])
}

deny contains msg if {
	some c in containers
	c.securityContext.privileged == true
	msg := sprintf("%s/%s container %s must not be privileged", [input.kind, name, c.name])
}

deny contains msg if {
	some c in containers
	not "ALL" in object.get(object.get(c.securityContext, "capabilities", {}), "drop", [])
	msg := sprintf("%s/%s container %s must drop ALL capabilities", [input.kind, name, c.name])
}

deny contains msg if {
	some c in containers
	some r in ["cpu", "memory"]
	not c.resources.limits[r]
	msg := sprintf("%s/%s container %s must set %s limits", [input.kind, name, c.name, r])
}

deny contains msg if {
	some c in containers
	not contains(c.image, "@sha256:")
	msg := sprintf("%s/%s container %s image must be pinned by digest", [input.kind, name, c.name])
}

deny contains msg if {
	input.kind == "Namespace"
	object.get(object.get(input.metadata, "labels", {}), "pod-security.kubernetes.io/enforce", "") != "restricted"
	msg := sprintf("Namespace/%s must enforce the restricted Pod Security level", [name])
}

deny contains msg if {
	input.kind == "ServiceAccount"
	not input.metadata.annotations["iam.gke.io/gcp-service-account"]
	msg := sprintf("ServiceAccount/%s must carry the iam.gke.io/gcp-service-account annotation", [name])
}

deny contains msg if {
	input.kind == "NetworkPolicy"
	name == "default-deny"
	count(object.get(input.spec, "podSelector", {"x": 1})) != 0
	msg := "NetworkPolicy/default-deny must select all pods with an empty podSelector"
}

deny contains msg if {
	input.kind == "NetworkPolicy"
	name == "default-deny"
	not {"Ingress", "Egress"} == {t | some t in object.get(input.spec, "policyTypes", [])}
	msg := "NetworkPolicy/default-deny must cover Ingress and Egress"
}

deny contains msg if {
	some field in ["hostNetwork", "hostPID", "hostIPC"]
	pod_spec[field] == true
	msg := sprintf("%s/%s must not use host namespaces (%s)", [input.kind, name, field])
}

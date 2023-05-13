title "Kubernetes Basics"

control "kubernetes_pod" do
  impact 1.0
  title "Validate built-in namespaces"
  desc "The kube-system, kube-public, and default namespaces should exist"

#   describe kubernetes_pod(api: 'v1', type: 'namespaces', name: 'kube-system') do
#     it { should exist }
#   end
#   describe k8sobject(api: 'v1', type: 'namespaces', name: 'banking-cco-dev1') do
#     it { should exist }
#   end
#   describe k8sobject(api: 'v1', type: 'namespaces', name: 'banking-aet-dev1') do
#     it { should exist }
#   end
#   describe k8sobject(api: 'v1', type: 'namespaces', name: 'banking-lao-dev1') do
#     it { should exist }
#   end

describe kubernetes_pod(namespace: 'banking-cco-dev1') do
    it { should exist }
    it { should be_running }
  end
end

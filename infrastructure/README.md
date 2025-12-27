# Hướng dẫn triển khai Kubernetes với Terragrunt + Kubespray

Tài liệu này hướng dẫn **end‑to‑end** cách:

* Khởi tạo **Kubernetes cluster** (dev)
* Tạo **node group (worker groups)** kiểu EKS
* **Scale up / down** từng node group
* Quản lý **nhiều môi trường / nhiều cluster**

Áp dụng cho mô hình **self‑managed K8s** (Hetzner hoặc cloud tương tự).

---

## 1. Kiến trúc tổng thể

```
Terragrunt (Terraform)
  ├─ Network
  ├─ Control Plane VMs
  ├─ Worker Node Groups (app / ci / db ...)
  └─ Generate inventory.ini
           ↓
Kubespray (Ansible + kubeadm)
           ↓
Kubernetes Cluster
```

**Nguyên tắc:**

* Terraform/Terragrunt = **hạ tầng**
* Kubespray = **lifecycle Kubernetes**
* Node group = **folder + labels + taints** (không phải cloud object)

---

## 2. Cấu trúc thư mục

```
infra/
├── modules/
│   ├── network/
│   ├── vm/
│   └── inventory/
│
├── live/
│   └── dev/
│       └── cluster-dev/
│           ├── terragrunt.hcl        # root cluster config
│           ├── network/
│           │   └── terragrunt.hcl
│           ├── control-plane/
│           │   └── terragrunt.hcl
│           ├── worker-app/
│           │   └── terragrunt.hcl
│           ├── worker-ci/
│           │   └── terragrunt.hcl
│           ├── worker-db/
│           │   └── terragrunt.hcl
│           └── inventory/
│               └── terragrunt.hcl
│
└── kubespray/
    └── inventory/
        └── dev/
            └── cluster-dev/
                └── inventory.ini
```

---

## 3. Khởi tạo cluster (DEV)

### 3.1 Chuẩn bị

```bash
export HCLOUD_TOKEN=xxxx
export ANSIBLE_HOST_KEY_CHECKING=False
```

Cài:

* Terraform
* Terragrunt
* Ansible
* Python 3.9+

---

### 3.2 Tạo hạ tầng

```bash
cd infra/live/dev/cluster-dev
terragrunt run-all apply
```

Kết quả:

* Network được tạo
* Control plane VM
* Worker VMs theo từng node group
* File inventory cho Kubespray được generate

---

## 4. Node Group (giống EKS)

### 4.1 Khái niệm

| EKS        | Ở đây             |
| ---------- | ----------------- |
| Node Group | Folder Terragrunt |
| ASG        | count VM          |
| Label      | node_labels       |
| Taint      | node_taints       |

---

### 4.2 Ví dụ node group: worker-app

`live/dev/cluster-dev/worker-app/terragrunt.hcl`

```hcl
terraform {
  source = "../../../../modules/vm"
}

inputs = {
  role         = "worker"
  node_group   = "app"
  count        = 3
  server_type  = "cx31"
  cluster_name = "cluster-dev"
}
```

---

### 4.3 Labels & Taints trong Kubernetes

Inventory (auto generate):

```ini
worker-app-1 ansible_host=10.0.0.21 ip=10.0.0.21 \
  node_labels='{"node-group":"app"}'

worker-db-1 ansible_host=10.0.0.31 ip=10.0.0.31 \
  node_labels='{"node-group":"db"}' \
  node_taints='["db=true:NoSchedule"]'
```

Kubespray sẽ tự apply labels/taints khi deploy.

---

## 5. Deploy Kubernetes bằng Kubespray

```bash
cd kubespray
ansible-playbook -i inventory/dev/cluster-dev/inventory.ini cluster.yml -b
```

Lấy kubeconfig:

```bash
export KUBECONFIG=inventory/dev/cluster-dev/artifacts/admin.conf
kubectl get nodes
```

---

## 6. Scale node group

### 6.1 Scale UP worker-app

```bash
cd infra/live/dev/cluster-dev/worker-app
# sửa count = 5
terragrunt apply
```

Sau đó chạy lại Kubespray để join node:

```bash
cd kubespray
ansible-playbook -i inventory/dev/cluster-dev/inventory.ini scale.yml -b
```

---

### 6.2 Scale DOWN worker-app

```bash
kubectl cordon worker-app-5
kubectl drain worker-app-5 --ignore-daemonsets --delete-emptydir-data
```

```bash
cd infra/live/dev/cluster-dev/worker-app
# giảm count = 3
terragrunt apply
```

---

## 7. Deploy workload theo node group

### 7.1 App workload

```yaml
nodeSelector:
  node-group: app
```

---

### 7.2 DB workload (taint)

```yaml
tolerations:
- key: "db"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"
```

---

## 8. Import resource có sẵn

### Import network

```bash
cd network
terragrunt import hcloud_network.this <NETWORK_ID>
```

### Import VM

```bash
terragrunt import hcloud_server.this[0] <SERVER_ID>
```

---

## 9. Quản lý nhiều cluster

```
live/
├── dev/cluster-dev
├── staging/cluster-stg
└── prod/cluster-prod
```

Mỗi cluster:

* State riêng
* Inventory riêng
* Kubeconfig riêng

---

## 10. Checklist production-ready

* [ ] Labels & taints rõ ràng
* [ ] State tách theo cluster
* [ ] Không dùng admin token cho CI
* [ ] Backup etcd
* [ ] Monitoring (Prometheus)
* [ ] GitOps (ArgoCD)

---

## 11. Lệnh thường dùng

```bash
# Xem node theo group
kubectl get nodes --show-labels

# Scale group
git diff && terragrunt apply

# Upgrade cluster
ansible-playbook upgrade-cluster.yml -b
```

---

## 12. Tổng kết

✔ Thiết kế giống EKS nhưng **linh hoạt hơn**
✔ Không lock cloud
✔ Scale / upgrade chủ động
✔ Dùng được cho production

---

**End of guide**

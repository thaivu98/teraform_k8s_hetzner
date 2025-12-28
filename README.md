# Hetzner Kubernetes Infrastructure (Terragrunt + Kubespray)

Dự án này cung cấp giải pháp triển khai Kubernetes Cluster trên Hetzner Cloud sử dụng **Terragrunt** để quản lý hạ tầng và **Kubespray** để cài đặt K8s.

## 1. Kiến Trúc Tổng Quan

Mô hình hoạt động theo luồng:
1.  **Terragrunt (Infrastructure)**:
    *   Tạo Network, Load Balancers, và VPC.
    *   Tạo các **VM** theo từng **Node Group** (ví dụ: `control-plane`, `worker-1`, `worker-2`).
    *   Module `inventory` tự động tổng hợp IP của các VM và sinh ra file `inventory.ini` chuẩn cho Kubespray.
2.  **Kubespray (Configuration)**:
    *   Đọc file `inventory.ini` được sinh ra.
    *   Cài đặt Kubernetes, cấu hình Network Plugin (CNI), Container Runtime, v.v.

### Cấu Trúc Thư Mục
Mỗi Cluster là một thư mục độc lập trong `infrastructure/live`. Mỗi **Node Group** là một thư mục con riêng biệt.

```
infrastructure/live/
├── production/
│   └── k8s-cluster-1/      # Tên Cluster
│       ├── network/        # Config mạng
│       ├── control-plane/  # Node Group Control Plane
│       ├── worker-1/       # Node Group Worker 1
│       ├── worker-2/       # Node Group Worker 2
│       └── inventory/      # Tổng hợp và sinh inventory.ini
└── staging/
    └── website-staging/
        ├── ...
```

---

## 2. Hướng Dẫn Sử Dụng

### Điều kiện cần
*   Đã cài đặt: `terraform`, `terragrunt`, `ansible`, `hcloud` (CLI).
*   Đã set biến môi trường `HCLOUD_TOKEN`.

### A. Khởi Tạo Cluster Lần Đầu (A-Z)

Sử dụng script `deploy.sh` để chạy từ A-Z (Tạo infra -> Sinh inventory -> Cài K8s).

```bash
# Cú pháp: ./scripts/deploy.sh <môi_trường> <tên_cluster>
./scripts/deploy.sh staging website-staging
```

### B. Thêm Một Node Group Mới (Scale Up)

Ví dụ bạn muốn thêm một nhóm worker mới tên là `worker-3`.

1.  **Tạo thư mục mới**:
    Copy từ thư mục worker cũ (ví dụ `worker-1`) ra `worker-3`.
    ```bash
    cd infrastructure/live/staging/website-staging/
    cp -r worker-1 worker-3
    ```

2.  **Sửa config `worker-3/terragrunt.hcl`**:
    *   Sửa `nodegroup = "worker-3"`.
    *   Điều chỉnh `server_type`, `count` (số lượng node) tùy ý.

3.  **Khai báo vào `inventory/terragrunt.hcl`**:
    Mở file `infrastructure/live/staging/website-staging/inventory/terragrunt.hcl` và thêm dependency:

    ```hcl
    dependency "worker_3" {
      config_path = "../worker-3"
    }

    inputs = {
      # ...
      node_groups = {
        # ... các group cũ ...
        worker_3_group = {
          hosts  = dependency.worker_3.outputs.nodes
          labels = { "role" = "worker", "group" = "3" }
          taints = []
        }
      }
    }
    ```

4.  **Chạy Deploy**:
    ```bash
    ./scripts/deploy.sh staging website-staging
    ```
    *Script sẽ tự phát hiện node mới, cập nhật inventory và Kubespray sẽ join node vào cluster.*

### C. Xóa Một Node Group (Scale Down)

Ví dụ muốn xóa `worker-3`.

1.  **Xóa Infra của Group đó**:
    ```bash
    cd infrastructure/live/staging/website-staging/worker-3
    terragrunt destroy
    # Nhập 'y' để confirm xóa VM
    ```

2.  **Xóa khai báo trong Inventory**:
    *   Mở `inventory/terragrunt.hcl`.
    *   Xóa block `dependency "worker_3"` và block `worker_3_group` trong `node_groups`.

3.  **Cập nhật lại Cluster**:
    Chạy lại deploy để Kubespray biết inventory mới (loại bỏ các node đã chết).
    ```bash
    ./scripts/deploy.sh staging website-staging
    ```
    *Lưu ý: Để sạch sẽ hơn, bạn nên `kubectl drain` và `kubectl delete node` các node đó thủ công trước khi destroy VM.*

### D. Quản Lý Bật/Tắt (Tiết Kiệm Chi Phí)

Dùng script `power-mgmt.sh` để tắt các node group không dùng (ví dụ môi trường Dev/Staging vào ban đêm).

```bash
# Tắt toàn bộ group worker-1 của cluster website-staging
./scripts/power-mgmt.sh website-staging worker-1 off

# Bật lại
./scripts/power-mgmt.sh website-staging worker-1 on
```

---

## 3. Automation Scripts

*   **`scripts/deploy.sh`**: Orchestrator chính. Chạy Terragrunt để tạo hạ tầng, sau đó gọi Ansible Kubespray.
*   **`scripts/power-mgmt.sh`**: Quản lý bật tắt VM dựa trên label `cluster` và `nodegroup` của Hetzner.

Windows Host
    │
    └── VMware Workstation
          │
          ├── VMnet10
          │     192.168.10.0/24
          │     Management
          │
          └── VMnet20
                192.168.20.0/24
                Storage / NFS
                    │
        ┌───────────┼─────────────┐
        │           │             │
     TrueNAS      CentOS        Ubuntu
    .20.181       Storage       Storage
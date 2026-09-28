                    MANAGEMENT NETWORK
                     192.168.10.0/24
                           │
              ┌────────────┴────────────┐
              │                         │
        CentOS Admin              TrueNAS Management
                                   │
                                   │
========================= VMnet20 =========================
                     STORAGE NETWORK
                    192.168.20.0/24
                           │
              ┌────────────┴────────────┐
              │                         │
        CentOS Storage NIC       Ubuntu Storage NIC
              │                         │
              └───────────┬─────────────┘
                          │
                    NFS / NFSv4
                          │
                   ┌──────▼──────┐
                   │   TrueNAS   │
                   │ .20.181     │
                   └──────┬──────┘
                          │
                     ZFS Pool
                          │
                   storage_tank
                          │
             ┌────────────┼─────────────┐
             │            │             │
         production    nfs-lab       backup
                          │
              ┌───────────┼──────────┐
              │           │          │
           shared     griffindor  slytherin
                                      │
                                  restricted
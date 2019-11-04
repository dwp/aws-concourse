[Unit]
Description=Concourse CI Worker

[Service]
%{ for key, value in environment_vars ~}
Environment=${key}=${value}
%{ endfor ~}

ExecStart=/usr/local/concourse/bin/concourse worker

User=root
Group=root
Type=simple
LimitNPROC=infinity
LimitNOFILE=infinity
TasksMax=infinity
MemoryLimit=infinity
Delegate=yes
KillMode=none

[Install]
WantedBy=default.target

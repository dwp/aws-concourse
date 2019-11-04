[Unit]
Description=Concourse CI Web

[Service]
%{ for key, value in environment_vars ~}
Environment=${key}=${value}
%{ endfor ~}

ExecStart=/usr/local/concourse/bin/concourse web

User=root
Group=root

Type=simple

LimitNOFILE=20000

[Install]
WantedBy=default.target

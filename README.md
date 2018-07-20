[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/dreik/ZabbixMSSQL/blob/master/LICENSE)

# ZabbixMSSQL
Zabbix Template and tools for Microsoft SQL Server

This template is PoC due to the nature of SQL monitoring (every DBA would have to his own things depending on the type of load):
- There is no triggers;
- There is no graphs, etc;
- You can easily extend SP to get metrics you need from your MSSQL even business metrics.

## Requirements
* Zabbix > 3.4
* Microsoft SQL Server > 2008 R2
* .Net Framework > 4.0

## Installation
1. Import ZabbixMSSQL.xml template into your Zabbix and attach to SQL server.
2. Execute `ZabbixMSSQL.sql` on your SQL server.
2. Add `ZabbixMSSQL.conf` content into your `zabbix_agentd.conf`. Don't forget to modify paths to binaries according to your installation.
3. Compile .Net apps and copy binaries with dlls to path configured above. (pre-compiled binaries are available in Releases).
4. Restart Zabbix Agent service.

#### Influenced by
- [How to install Zabbix 3.4 monitoring server on Ubuntu 16.04 LTS](http://yallalabs.com/linux/how-to-install-zabbix-3-4-monitoring-server-on-ubuntu-16-04-lts/)
- [go-zabbix-mssql](https://github.com/khannz/go-zabbix-mssql) by khanz
- [Стиль жизни SQL](http://sqlcom.ru/) and their [Telegram group](https://t.me/sqlcom)
- [Zabbix Talks](https://t.me/ZabbixPro) telegram group (RU)
- [Zabbix plugin for Grafana](https://github.com/alexanderzobnin/grafana-zabbix)
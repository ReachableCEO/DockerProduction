<?php

$config['db_host'] = getenv('DB_HOST');
$config['db_port'] = getenv('DB_PORT');
$config['db_user'] = getenv('DB_USER');
$config['db_pass'] = getenv('DB_PASS');
$config['db_name'] = getenv('DB_NAME');

// Redis settings (used for distributed polling)
$config['redis']['host'] = getenv('REDIS_HOST');
$config['redis']['port'] = getenv('REDIS_PORT');
$config['redis']['db'] = getenv('REDIS_DB');
$config['redis']['pass'] = getenv('REDIS_PASS');

// Base URL
$config['base_url'] = getenv('APP_URL');

// Authentication mechanism - This will be modified by start.sh if needed
$config['auth_mechanism'] = 'mysql';

// Enable alerting
$config['alert']['enable'] = true;

// RRD storage
$config['rrd_dir'] = '/app/data/rrd';

// Log directory
$config['log_dir'] = '/app/data/logs';
$config['log_file'] = '/app/data/logs/librenms.log';
$config['auth_log'] = '/app/data/logs/auth.log';

// Plugin directory 
$config['plugin_dir'] = '/app/data/plugins';

// Default theme
$config['webui']['default_theme'] = 'light';

// Path settings
$config['fping'] = '/usr/bin/fping';
$config['fping6'] = '/usr/bin/fping6';
$config['snmpwalk'] = '/usr/bin/snmpwalk';
$config['snmpget'] = '/usr/bin/snmpget';
$config['snmpbulkwalk'] = '/usr/bin/snmpbulkwalk';
$config['snmptranslate'] = '/usr/bin/snmptranslate';
$config['rrdtool'] = '/usr/bin/rrdtool';
$config['whois'] = '/usr/bin/whois';
$config['ping'] = '/bin/ping';
$config['mtr'] = '/usr/bin/mtr';
$config['nmap'] = '/usr/bin/nmap';

// Disable in-app updates
$config['update'] = 0;

// Security settings
$config['allow_unauth_graphs'] = false;
$config['allow_unauth_graphs_cidr'] = array();

// Alert tolerance window
$config['alert']['tolerance_window'] = 5;

// Poller settings
$config['poller_modules']['bgp'] = 1;
$config['poller_modules']['ospf'] = 1;
$config['poller_modules']['isis'] = 1;
$config['poller_modules']['applications'] = 1;
$config['poller_modules']['services'] = 1;

// Set timezone according to Cloudron environment
$config['timezone'] = 'UTC';

// Auto-discovery settings
$config['autodiscovery']['xdp'] = true;
$config['autodiscovery']['ospf'] = true;
$config['autodiscovery']['bgp'] = true;
$config['autodiscovery']['snmpscan'] = true;

// API Settings
$config['api']['cors']['enabled'] = false;
$config['api']['cors']['origin'] = null;

// Rate Limiting
$config['ratelimit']['enabled'] = true;
$config['ratelimit']['api']['limit'] = 300;
$config['ratelimit']['api']['period'] = 60;

// Default alert rules
$config['enable_inventory'] = 1;
$config['enable_syslog'] = 0;
import  os

c.ServerProxy.servers.update(
  {'phppgadmin': {
    'command': ["/usr/sbin/apache2ctl","start"],
    'new_browser_tab': False,
    'port': 80,
    'timeout': 20,
    "absolute_url": True,
    'launcher_entry': {
      'title': 'PHP PgAdmin',
      'icon_path': os.path.join(
                os.path.dirname(os.path.abspath(__file__)), "icons", "postgresql-icon.svg"),
    }
  }
}
)


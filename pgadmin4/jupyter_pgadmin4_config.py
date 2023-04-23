import  os
import site

c.ServerProxy.servers.update(
  {'pgadmin4': { 
    'command': ["gunicorn",
                "--bind",'127.0.0.1:{port}',
                '-e', 'SCRIPT_NAME={base_url}pgadmin4',
                '--chdir', os.path.join(site.getsitepackages()[0], 'pgadmin4'),
                "pgAdmin4:app",],
    'absolute_url': True,
    'timeout': 120,
    'launcher_entry': {
      'title': 'PgAdmin 4',
      'icon_path': os.path.join(
                os.path.dirname(os.path.abspath(__file__)), "icons", "postgresql-icon.svg"),
    }
  }
 }
)


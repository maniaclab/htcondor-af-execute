"""Application exporter"""

import os
import time
from subprocess import check_call
from prometheus_client import start_http_server, Gauge, Enum
import requests
import threading
import sys


class AppMetrics:
    """
    Representation of Prometheus metrics and loop to fetch and transform
    application metrics into Prometheus metrics.
    """

    def __init__(self, paths=None, app_port=80, polling_interval_seconds=30):
        self.app_port = app_port
        self.polling_interval_seconds = polling_interval_seconds
        if not paths:  
            paths=["/cvmfs/atlas.cern.ch/repo/",
                   "/cvmfs/sft.cern.ch/lcg",
                   "/cvmfs/atlas-condb.cern.ch/repo",
                   "/cvmfs/sft-nightlies.cern.ch/lcg",
                   "/cvmfs/atlas-nightlies.cern.ch/repo/",
                   "/cvmfs/oasis.opensciencegrid.org/cmssoft/",
                   "/cvmfs/unpacked.cern.ch/registry.hub.docker.com"]

        self.paths = paths

        # Prometheus metrics to collect
        #self.current_requests = Gauge("app_requests_current", "Current requests")
        #self.pending_requests = Gauge("app_requests_pending", "Pending requests")
        #self.total_uptime = Gauge("app_uptime", "Uptime")
        self.health = Enum("cvmfs_health", "Health", ["path"], states=["healthy", "unhealthy"])

    def run_metrics_loop(self):
        """Metrics fetching loop"""

        while True:
            if threading.active_count() != 2:
                print(f"Unexpected threadcount: {threading.active_count()}, so exit the program")
                sys.exit(1)

            self.fetch()
            time.sleep(self.polling_interval_seconds)

    def fetch(self):
        """
        Get metrics from application and refresh Prometheus metrics with
        new values.
        """

        # Fetch raw status data from the application
        #resp = requests.get(url=f"http://localhost:{self.app_port}/status")
        #status_data = resp.json()

        # Update Prometheus metrics with application metrics
        #self.current_requests.set(status_data["current_requests"])
        #self.pending_requests.set(status_data["pending_requests"])
        #self.total_uptime.set(status_data["total_uptime"])

        for p in self.paths:
            try:
                check_call(['test', '-e', p], timeout=10)
            except:
                self.health.labels(path=p).state("unhealthy")
            else:
                self.health.labels(path=p).state("healthy")
            # thread could stuck in D wait and result will be stale
            #if os.path.exists(p):
            #    self.health.labels(path=p).state("healthy")
            #else:
            #    self.health.labels(path=p).state("unhealthy")

def main():
    """Main entry point"""
    cvmfs_paths = os.getenv("CVMFS_PATHS", None)
    
    polling_interval_seconds = int(os.getenv("POLLING_INTERVAL_SECONDS", "5"))
    app_port = int(os.getenv("APP_PORT", "80"))
    exporter_port = int(os.getenv("EXPORTER_PORT", "9877"))

    app_metrics = AppMetrics(
        app_port=app_port,
        polling_interval_seconds=polling_interval_seconds,
        paths=cvmfs_paths.split(',') if cvmfs_paths else None
    )
    start_http_server(exporter_port)
    app_metrics.run_metrics_loop()

if __name__ == "__main__":
    main()

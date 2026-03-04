# Operations Engineering 2 Group C


## Lab 2.1

**4 March 2026, 10.15 - 10.49PM**

**Server Hostname**: `backup-c`

### Reflection on `systemd`:

The `hello.service` exercise highlighted the fundamental vulnerabilities of manual process management or through basic scripts. Running the script exposed several issues that should never be pushed to a production environment.

If there is no restart policy for the script, it would remain dead and would require manual intervention.

Running the script as `root` also poses a major security risk. When compromised it would allow attackers to obtain full system access.

`systemd` helps mitigate these problems by migrating from an imperative execution model to a declarative unit model. By implementing the Principle of Least Privilege, it ensures the `hello.service` service was ran by a dedicated user (`diskmon`) with minimial permissions. 

`systemd` also provides automated recovery when services like `hello.service` fail. It accomplishes this through restarting services upon failure, ensuring better service recovery. `systemd` also allows services to recover within a defined window of time.

Last of all, `systemd`'s journaling system `journalctl` resolves the issue of fragmented logging. Instead of scrambling for text files, helpful metadata providing useful information such as PIDs, UIDs and timestamps allows for more robust and rapid troubleshooting that simple background scripts cannot provide.

So in summary `systemd` extracts away alot of the heavy tasks that come with manual service management, and provides a more robust, efficient and more automated solution for service management.





# Operations Engineering 2 Group C


## Lab 2.2

**6 March 2026, 2:32pm -3:39pm**

**Server Hostnames**: `mgmt-c`, `backup-c`, `app-c`, `db-c`

**Main obejective:**
- Setting up a Puppet Server which would be referred to as the "master" and Puppet Agent nodes, establishing secure communication between them and applying manifests. 
- The goal was to understand how configuration management tools enforce desired state and reduce configuration drift across multiple machines.

---
 

### Puppet  

- **Puppet Server** — compiles catalogs and manages certificates  
- **Puppet Agents** — request catalogs and enforce configuration  
- **SSL Certificates** — ensure secure and trusted communication  


### Declarative vs Imperative Thinking  
A major takeaway was shifting from an **imperative** mindset “Do these steps in this order” to a **declarative** one “This is the state the system should be in”  


### Summary
 Puppets declarative structure removes the stress of having to write step by step shell scripts and instead lets us define the final state we want. It removes much of the manual effort involved in maintaining configurations and provides a more consistent, automated, and reliable way to manage systems across multiple machines.





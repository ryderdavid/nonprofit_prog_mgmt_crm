# CRM For Nonprofit Development Program Management

## Project Direction Overview

This project is a mock PostgreSQK CRM customized for use to manage numerous aspects of grant program management for a typical nonprofit organization sending experts (paid or volunteer) to serve overseas projects. It is modeled after a legal and justice sector nonprofit. 

The database will assist employees with key knowledge management functions, such as tracking engagement history with experts, keeping logged their skills and CVs. Another function currently being built out will be providing analytics on current and past awards, their managers, donors, and key contacts. A future function will include tracking new business development, including logging opportunities, proposals, win/loss rates, competitors, and winners, and if won by us, the projects they turned into.

This is both an exercise in conceptually mapping business use cases in data management of a nonprofit, and to build my skills in UML and RDBMs design and implementation.

## Use cases supported:

1. Entry of a person in the system, as Expert or employee
2. Collection of addresses
3. Recording of engagements by experts
4. Maintenance of organizational focal areas, by which experts and programs are classified under numerous "tags" organizing the types of activities the program supports (human rights, criminal law, etc).
5. Entry and maintenance of program records
6. Entry and maintenance of program manager records

## Future use cases:
7. Donor organizations
8. Donor contacts
9. Funding Opportunity tracking
10. Proposal tracking

## Physical entity relationship diagram
![Physical ERD](https://github.com/ryderdavid/cs_669_crm_rdbms/blob/master/ERD/physical_ERD_posgres.png "Physical ERD")

## To deploy the database:
1. Run all commands in the `setup_script.sql` file (uncomment the first line if you want to create a new database).
2. Run all commands in the `stored_procs.sql` file.
3. Run all commands in the `add_records.sql` file, if you wish to populate the database with some default and sample records.

Queries are in `queries.sql`.

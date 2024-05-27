#Multiple projects and its respective repo's automation with admin and dev access  
# tmcr.sh  
#Shell script - we are defining project names and teams manually in shell script (tmcr.sh)  
#projA(rp1 to rp5 have admin and dev level of access)  
#projB(rpb1 to rpb5 have admin and dev level of access)  
#Note:while running the workflow enable the permission line and execution of script line in main.yml

# tmcr1.sh
#Shell script - Automatically checking the  project names and teams are assigned in shell script (tmcr1.sh)  
#All projects under org will have admin and dev level of access
#Note:while running the workflow enable the permission line and execution of script line in main.yml

![image](https://github.com/RafiCisco/Projects/assets/33840574/bc84208e-b32e-4ade-879f-3cf82e90ebb4)


# tmcr2.sh
#shell script - Automation shell script to display organization name and its respective repository       
#Through shell script automation display Projects and their repositories reading from repos.json  
#Assigning teams (admin & dev) to the Projects present in repos.json  
#output  
Repositories under the organization: RafiCisco  
  / Projects  
  / projA  
  / rp1  
  / rp2  
  / projB  
Projects and their repositories reading from repos.json:  
Project: projA  
Repositories:  
  / rp1  
  / rp2  
  / rp3  
  / rp4  
  / rp5  
Project: projB  
Repositories:  
  / rpb1  
  / rpb2  
  / rpb3  
  / rpb4  
  / rpb5  
Assigning teams (admin & dev) to the Projects present in repos.json:  
Project: projA  
Dev team assigned to project projA  
Admin team assigned to project projA  
--------------------  
Project: projB  
Dev team assigned to project projB  
Admin team assigned to project projB  
--------------------  


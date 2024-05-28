#Multiple projects and its respective repo's automation with admin and dev access  
# tmcr.sh  
#Shell script - we are defining project names and teams manually in shell script (tmcr.sh)  
#projA(rp1 to rp5 have admin and dev level of access)  
#projB(rpb1 to rpb5 have admin and dev level of access)  
#Note:while running the workflow enable the permission line and execution of script line in main.yml

# tmcr1.sh
#Shell script - Automatically checking the  project names and teams are assigned through shell script (tmcr1.sh)  
#All projects under org will have admin and dev level of access
#Note: Uncomment the permission line and execution line of script (tmcr1.sh) in main.yml after that run the workflow  
Output of the workflow and script  
![image](https://github.com/RafiCisco/Projects/assets/33840574/bc84208e-b32e-4ade-879f-3cf82e90ebb4)

# tmcr2.sh
#Shell script - repos.json as input file in shell script
#Checks the teams and will create the teams,  projects under json file will have admin and dev level of access
#Note:while running the workflow enable the permission line and execution of script line (tmcr2.sh) in main.yml  
Output of the workflow and script

![image](https://github.com/RafiCisco/Projects/assets/33840574/74fa9ae5-59da-4706-96f9-a8ee8c868e04)  
repos.json file format  
![image](https://github.com/RafiCisco/Projects/assets/33840574/658ebf28-e9ce-48ab-93dd-e7cdfe9ee2da)  

# tmcr3.sh
#Shell script - repos.json as input file in shell script
#Checks the teams and will create the teams,  projects under json file will have admin and dev level of access
#Note:while running the workflow enable the permission line and execution of script line (tmcr3.sh) in main.yml  
Output of the workflow and script
![image](https://github.com/RafiCisco/Projects/assets/33840574/6cf4ec28-46ab-4faf-a5d4-a2bfb8447c72)  
repos.json file format  
![image](https://github.com/RafiCisco/Projects/assets/33840574/397c8866-4b9f-4bdc-a3df-b71d4ae8ec4f)

#!/usr/bin/bash 
shopt -s extglob
#To Make Regular Expressions work
echo DataBase Management System
PS3="Choose a Number:"
#i will check if the database dir is created
if [[ -d ~/DataBash ]]
then 
	cd ~/DataBash
else
	mkdir ~/DataBash
	cd ~/DataBash
fi

function DBOptions {
	select choice in "Create DataBase" "List DataBase" "Connect to DataBase"  "Drop DataBase" "Exit" 
	do
		case $REPLY in 
			1) echo "Create DataBase"
				createDatabase
				;;
			2) echo "List DataBase"
                                listDatabase
                                ;;
			3) echo "Connect to DataBase"
                                connectDatabase
                                ;;
			4) echo "Drop DataBase"
                                dropDatabase
                                ;;

			5) echo "Exit"
				cd 
				break
				;;
			*)echo "PLEASE CHOOSE A VALID OPTION"	
		esac
	done	
		}



function createDatabase {
	#ask the user about the database name and check if thier another one with the same name
	read -p "please enter your database name : " databaseName
	if [[ -d ~/DataBash/$databaseName ]]
	then
		echo "This database  already EXSISTS"
	else
		mkdir ~/DataBash/$databaseName;
		echo "Your database" $databaseName "has been created successfuly"
		DBOptions
	fi
}
function listDatabase {
        if [[ -d ~/DataBash ]]
	then
		echo this is ur database:
		ls ~/DataBash
	else
		echo database not found
	fi
}
function connectDatabase {
        read -p "Enter the database you want to connect to :  " databaseName
	if [[ -d $databaseName  ]]
	then
		cd ~/DataBash/$databaseName 
		echo "You  successfuly connected to " $databaseName
                tablesMenu
	else
		echo "database "$databaseName" not found"
	fi
}
function dropDatabase {
        read -p "Please enter database name you want to delete" databaseName
	rm -ir ~/DataBash/$databaseName 2>>~/error
        # i will use "$?" to check exit status if $? > 0 ==> error,$? == 0 ==> true
	if [[ $? == 0  ]]
	then
		echo "database" $databaseName "has been deleted successfuly"
	else
		echo "database" $databaseName  "not found"
	fi
}



function tablesMenu {
	select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "exit"
	do
		case $REPLY in
			1 ) echo create table
				createTable
				;;
			2 ) echo List Tables
				ls
				;;
			3 ) echo Drop Table
				dropTable
				;;
			4 ) echo Insert Into Table
				insertInto
				;;
			5 ) echo Select From Table
				selectFrom
				;;
			6 ) echo Delete From Table
				deleteFrom
				;;
			7 ) echo Update Table	
				updateTable
				;;
			8 ) echo exit
				break
				;;
			* ) echo unvalid option
				;;				
		esac
	done
}


function createTable {
	read -p "Please enter table name : " tablename
	if [[ $tablename -ne " " ]]
	then
#check if there is any table with the same name in the database
		if [[ -f $tablename ]]
		then
			echo there is a table with the same name in the database
			tablesMenu
		fi
	fi
	colname=""
	coltype=""
	ispk=""
	metadata="column name:column type:is primary key?\n"
	primaryKey=""
        dtable=""

#i need to know num of columns, name and datatype of each column and check if this col is a pk

	read -p "Enter number of columns in table  $tablename : " numOfcol
	i=1
	 echo "please know that if u want to add a primary key you have to add it as the first column and it will be auto incremented"
	while [ $i -le $numOfcol ]
	do
		echo "please enter names of columns $i in table $tablename : " 
		read nameOfcol
		echo "please choose if the type of $nameOfcol is str or int?" 
		select choice in "int" "str"
		do
			case $choice in
				int ) typeOfcol="int"
					break
					;;
				str ) typeOfcol="str"
					break
					;;
				* ) echo "not valid datatype";;
			esac
		done
#as long as the user doen't check a coloumn as pk keep asking
		if [[ $i == 1 ]]
		then
			 if [[ $primaryKey == "" ]]
	                then

				echo "do u want to make this coloumn your primary key?"
       				select choice in "yes" "no"
       				do
        			        case $choice in
                       				 yes ) primaryKey="primary key"	       
				
							colname=${nameOfcol}":"
							coltype="int"":"
							ispk=${primaryKey}		
							metadata+="${colname}${coltype}${ispk}\n"
						
							break 
                                        	        ;;

                       				 no )
							colname=${nameOfcol}":"
							coltype=${typeOfcol}":"
							metadata+="${colname}${coltype}\n"
							break
						 	;;
                	       			 * ) echo "unvalid value" ;;
					
        	       			 esac
		   	     done
		     
			fi     
#once the user accept a col as a primary key stop asking and save the data of the rest of the cols as following
		else
				colname=${nameOfcol}":"
                        	coltype=${typeOfcol}":"
				metadata+="${colname}${coltype}\n"
		fi
		#i want to add the name of all the columns in the beginig of the the table
		if [[ $i == $numOfcol  ]]
		then
			dtable=$dtable$nameOfcol
		else
			dtable=$dtable$nameOfcol":"
		fi

		((i++))
	done
	
#now i will create 2 files one to save metadata and the other to save data of the table
#i will save the meta data in a hidden file

	touch .$tablename
	echo -e $metadata "\c">> .$tablename
	touch $tablename
	echo  $dtable "\c">> $tablename
#to ensure the files (tables) has been created successfuly
	if [[ $? == 0 ]]
	then 
		echo "ur table $tablename has been created successfuly"
		tablesMenu
	else
		echo "sorry,there is a problem un creating table $tablename"
		tablesMenu
	fi
}


function insertInto {
	read -p "Please enter table name : " tablename
#check there is a table with this name in database
                if ! [[ -f $tablename ]]
                then
                        echo "table $tablename is not found"
                        tablesMenu
                fi
	
        
#i want to know all columns user should add a value for and it's type and check if it is primary key
  #at first i will check number of columns i colud ask user to add value for	
	columnumber=`awk 'END{print NR}' .$tablename`
	i=2
	field_value=""
	rowdata=""
#as first column has a decleration for columns name so i will start from i=2	
	while [ $i -lt $columnumber ]
	do
		
		#columname=`cut -f1 -d":" .$tablename`
	        #coltype=`cut -f2 -d":" .$tablename`	
		#ispk=`cut -f3 -d":" .$tablename`
			columname=$(awk -F: '{ if(NR=='$i') print $1}' .$tablename)
	        	coltype=$(awk -F: '{ if(NR=='$i') print $2}' .$tablename)	
			ispk=$(awk -F: '{ if(NR=='$i') print $3}' .$tablename)
			
#if this column is pk i will add a unique value for it to avoid it may be repeated	
		function take_val {
				echo "please enter the value u want to add in column $columname in a type $coltype" 
				read field_value
				
				function checktype {	

					if [[ $coltype = "str" ]]
					then
				 		case $field_value in
							+([a-zA-Z])) echo "accepted value"
								;;
							*) echo "ops,wrong value!!"
								#$field_value=""
								take_val
								 
								 ;;	  
						esac	       
					elif [[ $coltype = "int" ]]
					then
						case $field_value in
							+([0-9])) echo "accepted value"
							                 
								;;
							*) echo "ops,wrong value!!"
	  				                	#$field_value="" 
				 			 	take_val 
								  
							         ;;
						esac    
					fi
				
				}
				checktype
			}
					


			function check_pk {
				if [[ $i -eq 2 ]]
				then	
					if [[ $ispk = "primary key" ]]
					then
						seq_pk=$(awk 'END{ print NR}' $tablename)					
						echo -e "$seq_pk\c" >>$tablename	
						((seq_pk++))
						
					else
						take_val
					fi
				else 
					take_val	
				fi
		}

			
		
			
			check_pk
			
#set row of data in the table file
	if [[ $i -eq $columnumber ]]
#this mean he should add data then start new line
		rowdata+="${field_value}"
	then 
#this mean he will keep entering data in the same row so sperate after col with :
		rowdata+="${field_vale}":""
	fi		
	((i++))	

done
#know i want to add rowdata in the table file and to keep the cursor in the same line "\c"
	echo -e $rowdata>> $tablename
#to ensure the data has been added successfuly
	if [[ $? == 0 ]]
	then
		echo "data inserted successfuly"
		tablesMenu
	else
		echo "ops,there is an error in inserting ur data, please try again"
		tablesMenu
	fi

#now reset value of rowdata so the user will have the ability to add data for know row from a begining
rowdata=""
 tablesMenu
}


	function selectFrom {
	  	read -p "Enter Table Name: " tName
	  	

	  	if ! [[ -f $tName ]];
		then
		        echo "Table $tName isn't existed ,choose another Table";
			tablesMenu;
		fi

		read -p "Enter The Column Name " field
#this line cheeks if field exists and prints it on the terminal
	  	fid=$(sed -n f/$field/p $tName)
	#       fid=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}'$tName
	  	echo $fid	
		if [[ $fid == "" ]]
	  	then
	    		echo "Not Found"
	    		tablesMenu;
	  	else
			read -p "Enter The Value You Would Like To Search For  : " val 
#this line cheeks for the word "val" and prints it 
		        res=$(sed -n /$val/p $tName)
		        echo $res
	tablesMenu
	  fi
	}

	function deleteFrom {
	  	read -p "Enter Table Name: " tName
	  	

	  	if ! [[ -f $tName ]];
		then
		        echo "Table $tName isn't existed ,choose another Table";
			tablesMenu;
		fi
	       read -p "Enter The Value You Would Like To Search For  : " val 
	#This Line Checks the number of he word "val" in the file	 
	       
		if [[ ` grep -c -w "$val" $tName ` == 0 ]]
	  	then
	    		echo "Not Found"
	    		tablesMenu;
	  	else
#first it prints the line 
		        res=$(sed -n /$val/p $tName)
#then it deletes the file
		        sed -i /$res/d /$tName
	       echo "Record Deleted Successfully"
	tablesMenu
	  fi
	}
function dropDatabase {
	  	read -p "Enter Table Name: " tName
	  	

	  	if ! [[ -f $tName ]];
		then
		        echo "Table $tName isn't existed ,choose another Table";
			tablesMenu;
		fi
	      rm $tName
	   echo "DataBase Removed Successfully" 
	  tablesMenu
	}

function updateTable{
	deleteFrom
	insertInto

}
# function updateTable1 {
# echo "Enter The Table Name"
# read tName 
#   field=""	

#   	if ! [[ -f $tName ]];
#         then
#                 echo "Table $tName isn't existed ,choose another Table";
# 		tablesMenu;
# 	fi
# 	function colName {
# 		   read -p "Enter The Column Name  : " col
#             fnumber=`awk 'END{print $1, NF}' $tName`
# 	i=1
# 	 while [[ i -le $fnumber ]]	 
#      do
# 	columname=$(awk -F: '{ if(NF=='$i') print $i}' $tName)

#      if [[ $i -eq 1 ]] 
# 	 then
# 	 check_pk
#     fi 
	
# 	if [[ $columname == $col  ]] 
# 	$field=$i
#         updateVal	  
# 	else 
# echo "Column is not found "

# fi
# 	 done


# 	}
#   fid=$(awk -F : '{for(i=2;i<=NR;i++){if(NF=="'$field'")}}' $tName)

# 	function updateVal {
#                  read -p "Enter The Value You Would Like To Update  : " oldVal
# 				 	columnumber=`awk 'END{print NR}' $tName`
# 					j=2
#               fid=$(awk -F : '{if(NF=="'$field'")print $NF}' $tName)

# 					while [[ $j -le $columnumber ]]
# 			    do 
#                 if [[  ]]


# 				done
#                     sed -n '1,^'
#                         read -p "Enter The  New Value  : " newVal
#                      sed -i s/$oldVal/$newVal/g $tName
#                      echo "Data Has Been Updated Successfully 😎"
#                           tablesMenu
# 	}
# 		function check_pk {
# 				ispk=$(awk -F: '{ if(NR=='$2') print $3}' .$tName)
				
# 					if [[ $ispk = "primary key" ]]
# 					then
# 						echo " You Can't Update This Value"
						
# 					else
# 					 updateVal
# 					fi
				
# 		}
# }

DBOptions

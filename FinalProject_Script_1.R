############################### Setup #############################################

setwd("C:/Users/Rizky Januar/Desktop/Agent-Based Modelling/final project")


options(stringsAsFactors = TRUE)
install.packages("ggplot2")
library(ggplot2)
library(reshape2)
#install.packages("sqldf")
library(sqldf)

#to plot multiple graphs in one command
#install.packages("cowplot")
library("cowplot")

### reading the data ###

myDataFrame = read.table("experiments.csv", skip = 6, sep = ",", head=TRUE)
#summary(myDataFrame)

### cleans up the column names ###

colnames = colnames(myDataFrame)

###Some colnames start with "X.", get rid of this####
colnames(myDataFrame) = gsub("X\\.", "", colnames(myDataFrame))
# Get rid of periods at the start and end of the names
colnames(myDataFrame) = gsub("^\\.|\\.$", "", colnames(myDataFrame))
# Convert all periods into underscores
colnames(myDataFrame) = gsub("\\.", "_", colnames(myDataFrame))



############################### Analysis starts #############################################

#1. Open Exploration

basecase_data = subset(myDataFrame, Act_towards_recycling_target == 0 & init_contract_period ==36 )


a = ggplot(data=basecase_data, aes(x=step, y=average_recycling_rate_all_municipalities)) + 
  geom_line(color='blue') + 
  xlab("tick") +  
  ylab("average recycling rate of all municipalities")
#ggtitle("waste tax recycle graph") +
  #theme(plot.title = element_text(hjust = 0))
#print(a)
  
b = ggplot(data=basecase_data, aes(x=step, y=average_expenditure_all_municipalities)) + 
  geom_line(color='red') + 
  xlab("tick") +  
  ylab("average expenditure of all municipalities") 
#ggtitle("waste tax recycle graph") +
  #theme(plot.title = element_text(hjust = 0))
  #print(a)
  
#plot multiple graphs of same scale in one command
plot_grid(a, b, align='hv')

#################################
#2. Contract duration policy

#2.1 effect on capacity

#first, isolate policy awareness improvement out of the data
contractpolicy_data = subset(myDataFrame, Act_towards_recycling_target == 0 )

#change init_contract_period to strings
contractpolicy_data$init_contract_period <- factor(contractpolicy_data$init_contract_period, labels=c('Contract Policy','No Policy'))

#now see the effect of contract policy on firms' capacity
contract_policy_capacity_boxplot = ggplot(data=contractpolicy_data, aes(x=init_contract_period, y=average_capacity_all_firms, fill=init_contract_period)) + 
   geom_boxplot() +
   xlab("") +  
   ylab("average capacity") 
print(contract_policy_capacity_boxplot)
ggsave(contract_policy_capacity_boxplot, file="contract_policy_capacity_boxplot.png") 

####
  
#2.2. effect on efficiency

contract_policy_efficiency_boxplot = ggplot(data=contractpolicy_data, aes(x=init_contract_period, y=average_efficiency_all_firms, fill=init_contract_period)) + 
  geom_boxplot() +
  xlab("") +  
  ylab("average efficiency") +
  guides(fill=FALSE) +
  theme(panel.grid.major = element_line(color="azure3"))
print(contract_policy_efficiency_boxplot)

#2.3. effect on recycling rate

contract_policy_recyclingrate_boxplot = ggplot(data=contractpolicy_data, aes(x=init_contract_period, y=average_recycling_rate_all_municipalities, fill=init_contract_period)) + 
  geom_boxplot() +
  xlab("") +  
  ylab("average recycling rate of municipalities") +
  guides(fill=FALSE) +
  theme(panel.grid.major = element_line(color="azure3"))
print(contract_policy_recyclingrate_boxplot)

#################################
#3. proactiveness policy  

#3.1. effect on recycling rate

#first, isolate policy awareness improvement out of the data
proactivepolicy_data = subset(myDataFrame, init_contract_period == 36 )
  
#classify likelihood taking initiatives & frequency to review target to strings
proactivepolicy_data$Act_towards_recycling_target <- factor(proactivepolicy_data$Act_towards_recycling_target, labels=c('low','medium', 'high'))
proactivepolicy_data$municipal_initiative_frequency <- factor(proactivepolicy_data$municipal_initiative_frequency, labels=c('High', 'Medium', 'Low'))

#now see the effect of proactiveness policy on recycling rate
proactive_policy_recyclingrate_boxplot = ggplot(data=proactivepolicy_data, aes(x=municipal_initiative_frequency, y=average_recycling_rate_all_municipalities, fill=Act_towards_recycling_target)) + 
  geom_boxplot() +
  xlab("Frequency of Target Review") +  
  ylab("Average Recycling Rate of Municipalities") +
  labs(fill="Likelihood to take initiative")
  #+ facet_grid(~municipal_initiative_frequency)
  #theme( strip.text.x = element_blank(),
  #         strip.text.y = element_blank())
  
print(proactive_policy_recyclingrate_boxplot)
ggsave(proactive_policy_recyclingrate_boxplot, file="proactive_policy_recyclingrate_boxplot.png") 

#3.2. effect on expenditure

#now see the effect of proactiveness policy on expenditure
proactive_policy_expenditure_boxplot = ggplot(data=proactivepolicy_data, aes(x=municipal_initiative_frequency, y=average_expenditure_all_municipalities, fill=Act_towards_recycling_target)) + 
  geom_boxplot() +
  xlab("Frequency of Target Review") +   
  ylab("average expenditure of municipalities") +
  labs(fill="Likelihood to take initiative")
#theme( strip.text.x = element_blank(),
#         strip.text.y = element_blank())

print(proactive_policy_expenditure_boxplot)
ggsave(proactive_policy_expenditure_boxplot, file="proactive_policy_expenditure_boxplot.png") 


#############
#4. proactiveness + contract policy 

#basecase_data = subset(myDataFrame, Act_towards_recycling_target == 0 & init_contract_period ==36 )
highproactivepolicy_data = subset(myDataFrame, municipal_initiative_frequency == 1 & Act_towards_recycling_target == 1 & init_contract_period == 36 )
contractpolicy_proactivepolicy_data = subset(myDataFrame, municipal_initiative_frequency == 1 & Act_towards_recycling_target == 1 & init_contract_period == 3 )

combined_data <- rbind(highproactivepolicy_data, contractpolicy_proactivepolicy_data)
combined_data$init_contract_period <- factor(combined_data$init_contract_period, labels=c('Proactiveness + Contract Policy','Proactiveness Policy'))

#recycling rate

combined_policy_recyclingrate_boxplot = ggplot(data=combined_data, aes(x=init_contract_period, y=average_recycling_rate_all_municipalities, fill=init_contract_period)) + 
  geom_boxplot() +
  xlab("") +  
  ylab("average recycling rate of municipalities")+
  theme(panel.grid.major = element_line(color="azure3"))+
  guides(fill=FALSE)
print(combined_policy_recyclingrate_boxplot)


#expenditure
combined_policy_expenditure_boxplot = ggplot(data=combined_data, aes(x=init_contract_period, y=average_expenditure_all_municipalities, fill=init_contract_period)) + 
  geom_boxplot() +
  xlab("") +  
  ylab("average expenditure of municipalities")+
  theme(panel.grid.major = element_line(color="azure3"))+
  guides(fill=FALSE)
print(combined_policy_expenditure_boxplot)


############################### end of analysis #############################################
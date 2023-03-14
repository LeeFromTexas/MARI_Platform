 #Sys.setenv(
# "AWS_ACCESS_KEY_ID" = "AKIAX7SO2J6NVJKG2SBE",
# "AWS_SECRET_ACCESS_KEY" = "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",
# "AWS_DEFAULT_REGION" = "us-east-1"
#)
import boto3
s3 = boto3.client('s3', aws_access_key_id="AKIAX7SO2J6NVJKG2SBE" ,␣
,→aws_secret_access_key="yhLvbWwtiPI7Li5Ca6ykRwVauFLSvgQaGhs5cyT5")
#s3.download_file('mikemorgananalyticsbucket','Mar2023_Subset.
,→rds','Mar2023_subset.rds')
#s3.list_buckets()
bucket_name = 'mikemorgananalyticsbucket'
file_name = 'Mar2023_Subset.csv'
s3.list_objects_v2(Bucket=bucket_name)
#s3.download_file(bucket_name, file_name, new_file_name)
s3.download_file(bucket_name, file_name, file_name)

import pandas as pd
df = pd.read_csv('Mar2023_Subset.csv')

for column_headers in df.columns:
print(column_headers)

training_subeq1 = df.filter(['TARGET1','GENDER','RACE','ETHNIC','MARSTAT','EDUC','EMPLOY','AGE','LIVARAG','PRIMINC','STFIPS','REGION','DIVISION','PSOURCE','NOPRIOR','FRSTUSE1'],axis=1)
print(training_subeq1.head())
import sklearn
from sklearn.model_selection import train_test_split
X = training_subeq1.drop('TARGET1',axis='columns')
Y = training_subeq1[['TARGET1']]
######################################################### run the model on multi-processor first
#this is the problem
X_train, X_test, y_train, y_test = train_test_split(X,Y, train_size=0.8)
print(X_train.shape)
print(y_train.shape)
from sklearn.ensemble import RandomForestClassifier as sklRF
import multiprocessing as mp
#sklearn Random Forest params
skl_rf_params = {
'n_estimators': 25,
'max_depth': 13,
'n_jobs': mp.cpu_count() }
skl_rf = sklRF(**skl_rf_params)
skl_rf.fit(X_train, y_train)
from sklearn.metrics import accuracy_score
print("sklearn RF Accuracy Score: " + str(accuracy_score(skl_rf.predict(X_test), y_test)) )
y_pred = skl_rf.predict( X_test )
print(y_pred)
#print(y_test.to_numpy())
###################################################################
del training_subeq1


training_subeq2 = df.filter(['TARGET2','GENDER','RACE','ETHNIC','MARSTAT','EDUC','EMPLOY','AGE','LIVARAG','PRIMINC','STFIPS','REGION','DIVISION','PSOURCE','NOPRIOR','FRSTUSE1'],axis=1)
print(training_subeq2.head())
import sklearn
from sklearn.model_selection import train_test_split
X = training_subeq2.drop('TARGET2',axis='columns')
Y = training_subeq2[['TARGET2']]
######################################################### run the model on multi-processor first
#this is the problem
X_train, X_test, y_train, y_test = train_test_split(X,Y, train_size=0.8)
print(X_train.shape)
print(y_train.shape)
from sklearn.ensemble import RandomForestClassifier as sklRF
import multiprocessing as mp
#sklearn Random Forest params
skl_rf_params = {
'n_estimators': 25,
'max_depth': 13,
'n_jobs': mp.cpu_count() }
skl_rf = sklRF(**skl_rf_params)
skl_rf.fit(X_train, y_train)
from sklearn.metrics import accuracy_score
print("sklearn RF Accuracy Score: " + str(accuracy_score(skl_rf.predict(X_test), y_test)) )
y_pred = skl_rf.predict( X_test )
print(y_pred)
#print(y_test.to_numpy())
###################################################################
del training_subeq2


training_subeq3 = df.filter(['TARGET3','GENDER','RACE','ETHNIC','MARSTAT','EDUC','EMPLOY','AGE','LIVARAG','PRIMINC','STFIPS','REGION','DIVISION','PSOURCE','NOPRIOR','FRSTUSE1'],axis=1)
print(training_subeq3.head())
import sklearn
from sklearn.model_selection import train_test_split
X = training_subeq3.drop('TARGET3',axis='columns')
Y = training_subeq3[['TARGET3']]
######################################################### run the model on multi-processor first
#this is the problem
X_train, X_test, y_train, y_test = train_test_split(X,Y, train_size=0.8)
print(X_train.shape)
print(y_train.shape)
from sklearn.ensemble import RandomForestClassifier as sklRF
import multiprocessing as mp
#sklearn Random Forest params
skl_rf_params = {
'n_estimators': 25,
'max_depth': 13,
'n_jobs': mp.cpu_count() }
skl_rf = sklRF(**skl_rf_params)
skl_rf.fit(X_train, y_train)
from sklearn.metrics import accuracy_score
print("sklearn RF Accuracy Score: " + str(accuracy_score(skl_rf.predict(X_test), y_test)) )
y_pred = skl_rf.predict( X_test )
print(y_pred)
#print(y_test.to_numpy())
###################################################################
del training_subeq3


training_subeq4 = df.filter(['TARGET4','GENDER','RACE','ETHNIC','MARSTAT','EDUC','EMPLOY','AGE','LIVARAG','PRIMINC','STFIPS','REGION','DIVISION','PSOURCE','NOPRIOR','FRSTUSE1'],axis=1)
print(training_subeq4.head())
import sklearn
from sklearn.model_selection import train_test_split
X = training_subeq4.drop('TARGET4',axis='columns')
Y = training_subeq4[['TARGET4']]
######################################################### run the model on multi-processor first
#this is the problem
X_train, X_test, y_train, y_test = train_test_split(X,Y, train_size=0.8)
print(X_train.shape)
print(y_train.shape)
from sklearn.ensemble import RandomForestClassifier as sklRF
import multiprocessing as mp
#sklearn Random Forest params
skl_rf_params = {
'n_estimators': 25,
'max_depth': 13,
'n_jobs': mp.cpu_count() }
skl_rf = sklRF(**skl_rf_params)
skl_rf.fit(X_train, y_train)
from sklearn.metrics import accuracy_score
print("sklearn RF Accuracy Score: " + str(accuracy_score(skl_rf.predict(X_test), y_test)) )
y_pred = skl_rf.predict( X_test )
print(y_pred)
#print(y_test.to_numpy())
###################################################################
del training_subeq4

training_subeq5 = df.filter(['TARGET5','GENDER','RACE','ETHNIC','MARSTAT','EDUC','EMPLOY','AGE','LIVARAG','PRIMINC','STFIPS','REGION','DIVISION','PSOURCE','NOPRIOR','FRSTUSE1'],axis=1)
print(training_subeq5.head())
import sklearn
from sklearn.model_selection import train_test_split
X = training_subeq5.drop('TARGET5',axis='columns')
Y = training_subeq5[['TARGET5']]
######################################################### run the model on multi-processor first
#this is the problem
X_train, X_test, y_train, y_test = train_test_split(X,Y, train_size=0.8)
print(X_train.shape)
print(y_train.shape)
from sklearn.ensemble import RandomForestClassifier as sklRF
import multiprocessing as mp
#sklearn Random Forest params
skl_rf_params = {
'n_estimators': 25,
'max_depth': 13,
'n_jobs': mp.cpu_count() }
skl_rf = sklRF(**skl_rf_params)
skl_rf.fit(X_train, y_train)
from sklearn.metrics import accuracy_score
print("sklearn RF Accuracy Score: " + str(accuracy_score(skl_rf.predict(X_test), y_test)) )
y_pred = skl_rf.predict( X_test )
print(y_pred)
#print(y_test.to_numpy())
###################################################################
del training_subeq5
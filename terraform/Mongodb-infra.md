Creater a VPC, 2 subnets, one private one public, set the route tables accordingly.
Include a Nat gateway so mongo can be able to be install on the ec2
Create a security group with access to only an sg of an app that will access mongo , this sg for the ec2 that will have the mongodb database, also configure otbund access to 443 
set the mongo database on the ec2 that should be on the private subnet using the security group mentioned before
also deploy an api gateway that should have access to the mongo db this trough a lambda that will have the app
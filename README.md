# API-INEGI-multiple_queries
Code for how to perform multiple queries in the API (Application Programming Interface) of INEGI, considering multiple years and multiple states of Mexico. The case analyzed is the income measured in minimum wages for the Employed population according to Sex from 2005 to 2022. In order to be able to carry out a spatial analysis.

First of all, you need to enter the [API INEGI](https://www.inegi.org.mx/servicios/api_indicadores.html) page to get the [Token](https://www.inegi.org.mx/app/desarrolladores/generatoken/Usuarios/token_Verify) that will serve as a personal password for the queries you want to make on the INEGI API page.

##Main parts of the code.

###Preparing the queries

First, 3 specific vectors are made:
1. Token
2. Localities (states)
3. Variable codes to consult.


```
key = "Previously queried token"
Localidades = "Code of the towns that you want to consult"
B1I = "Code of the variables to be consulted"
```

###Metadata Query


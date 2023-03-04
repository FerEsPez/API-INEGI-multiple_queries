# API-INEGI-multiple_queries
Code for how to perform multiple queries in the API (Application Programming Interface) of INEGI, considering multiple years and multiple states of Mexico. The case analyzed is the income measured in minimum wages for the Employed population according to Sex from 2005 to 2022. In order to be able to carry out a spatial analysis.

First of all, you need to enter the [API INEGI](https://www.inegi.org.mx/servicios/api_indicadores.html) page to get the [Token](https://www.inegi.org.mx/app/desarrolladores/generatoken/Usuarios/token_Verify) that will serve as a personal password for the queries you want to make on the INEGI API page.

The code allows the user to query multiple variables (more than the 10 allowed directly on the INEGI API page). In addition to consulting more than 1 entity at a time.

The final objective of the code is to be able to carry out a graphic (and statistical) analysis of the INEGI information in an automated, clean and processed way to use software such as Tableou, Power BI, for presentations, research, etc.

An example of a Tableau dashboard with the information extracted into the code. It should be noted that the entire dashboard is interactive and interconnected with each other.
![ExampleDashboard-Tableou](https://user-images.githubusercontent.com/85140481/222882743-d405071f-031f-418e-97a1-9863ea81569d.png)

#INCLUDE 'Protheus.ch'           
#INCLUDE 'Topconn.ch'
                       

/*/{Protheus.doc} MTA010NC
//Ponto de Entrada na função copiar do cadastro de Produtos, utilizado para 
NÃO copiar campos 
@author TI12 - Leandro Spiller
@since 26/03/2018
@version undefined
@type 0
/*/
User Function MTA010NC()
	
	Local aCpoNC := {}      
                       
    //Não copia campo tipo
	AAdd( aCpoNC, 'B1_TIPO' ) 
	AAdd( aCpoNC, 'B1_CONTA' )  
                 
	//Verifca se empresa Importa Dbgint
    If ValDBGint()
		AAdd( aCpoNC, 'B1_ORIGIMP' )
    Endif 
    
Return (aCpoNC)   


//Valida se Existe campo de importação do DBgint
Static Function ValDBGint()  
	
	Local cQueryEMP := "" 
	Local lRet      := .F. 

	cQueryEMP += " SELECT * FROM EMPRESAS "
	cQueryEMP += " WHERE INTEGRA_DBGINT = 'S' AND EMP_COD = '"+cEmpant+"' AND EMP_FIL = '"+cFilAnt+"' "
	If Select("EMPRESAS") <> 0
	  dbSelectArea("EMPRESAS")
	  EMPRESAS->(dbCloseArea())
	Endif	   
	
	TCQuery cQueryEMP NEW ALIAS "EMPRESAS" 
	EMPRESAS->(dbgotop())
	  
	//adiciona campo de Importação
	If  EMPRESAS->(!eof())
		lRet := .T.
	Endif 
	
	EMPRESAS->(dbCloseArea())    
	
Return lRet 
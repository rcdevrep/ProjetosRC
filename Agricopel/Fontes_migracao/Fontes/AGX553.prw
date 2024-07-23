#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"         
#INCLUDE "TOPCONN.CH"


User Function AGX553()
Local cQuery:= ""      
Local aCabec := {}		
Local aItens := {}
Local aLinha := {}
Private lMsHelpAuto := .T.
PRIVATE lMsErroAuto := .T.                                 

//Importacao de CTE da empresa Agricopel para Postos Agricopel

//Valida se esta na empresa correta

PREPARE ENVIRONMENT EMPRESA "20" FILIAL "01" MODULO "COM" TABLES "SF1","SD1","SA1","SA2","SB1","SB2","SF4"


If cEmpAnt <> "20" 
	Alert("Esta rotina deve ser utilizada somente nos Postos Agricopel!")
	Return()
EndIf    

CONOUT("ENTROU NA ROTINA")

//Crio Estrutura para carregar as filial  


aFil := {}
Aadd(aFil,{"FILIAL"		,"C",02,0})
Aadd(aFil,{"CNPJ"		,"C",14,0})

                  
If (Select("TRB") <> 0)
	dbSelectArea("TRB")
	dbCloseArea()
Endif

cArqCli := CriaTrab(aFil,.T.)
dbUseArea(.T.,,cArqCli,"TRB",.T.,.F.)
Indregua("TRB",cArqCli,"CNPJ",,,OemToAnsi("Selecionando Ordem..."))


//Carrego as filiais em um arquivo temporario para nao ficar 
//carregando a tabela de empresas.

DbSelectArea("SM0")                       
//dbgotop()
While SM0->(!Eof() .and. SM0->M0_CODIGO == "20")
	dbSelectArea("TRB")
	RecLock("TRB",.T.)
		TRB->FILIAL := SM0->M0_CODFIL
		TRB->CNPJ   := SM0->M0_CGC
	MsUnlock()
	
    SM0->(DbSkip())
EndDo                             

//Busco as informações da empresa agricopel

cQuery := "SELECT F2_DOC, F2_SERIE , F2_CLIENTE, F2_LOJA, F2_COND , F2_EMISSAO , F2_TPFRETE, A1_CGC , F2_EST, "
cQuery += "F2_TIPOCLI, F2_VALBRUT, F2_VALICM , F2_BASEICM, F2_VALMERC, F2_TIPO, F2_PLIQUI, F2_PBRUTO, F2_VALFAT, "
cQuery += "F2_ESPECIE, F2_PREFIXO , F2_MOEDA, F2_PLACA , F2_CHVCONH, A1_CGC "
cQuery += "FROM SF2010 (NOLOCK) F2  INNER JOIN SD2010 (NOLOCK) D2 "
cQuery += " ON F2_FILIAL = D2_FILIAL "
cQuery += " AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE INNER JOIN SA1010 (NOLOCK) A1 "
cQuery += " ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA WHERE F2_ORIIMP = 'AGX518' "
cQuery += " AND F2_EMISSAO > '20131201'  AND F2_DOC = '000002567'  AND F2.D_E_L_E_T_ <> '*'  AND D2.D_E_L_E_T_ <> '*'  AND A1.D_E_L_E_T_ <> '*' " 
                                                                                                                                     
If (Select("QRY_SF2") <> 0)
	dbSelectArea("QRY_SF2")	
	dbCloseArea()
Endif
	
cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "QRY_SF2"


dbSelectArea("QRY_SF2")
dbGoTop()
Do While !Eof()
	//Verifico qual a filial do lançamento no posto agricopel
	dbSelectArea("TRB")
	dbGoTop()
	cCodFil := ""
	While !eof() 
		If TRB->CNPJ == QRY_SF2->A1_CGC 
			cCodFil := TRB->FILIAL              
		EndIf
		TRB->(dbSkip())
	EndDo                                                                         
	
	//Continuo com o insert
	//dbSelectArea("QRY_SF2")          
	                                                                                         
	//Verifico se não tem CTE cadastrado para o fornecedor
	dbSelectArea("SF1")
	dbSetOrder(1)
	
	If dbSeek(cCodFil+QRY_SF2->F2_DOC+QRY_SF2->F2_SERIE+"000086"+"01"+"N") //Fornecedor fixo pois é somente agricopel
		CONOUT("Documento " + cCodFil + "/" + QRY_SF2->F2_DOC + "/" + QRY_SF2->F2_SERIE + " ja cadastrado")
		dbSelectArea("QRY_SF2")
			QRY_SF2->(dbSkip())
		Loop
	EndIf
	
	aCabec := {}		
	aItens := {}     
	
	//Preparo array para inserir o documento 
  	aadd(aCabec,{"F1_FILIAL"   ,cCodFil})
	aadd(aCabec,{"F1_DOC"      ,QRY_SF2->F2_DOC})	 
	aadd(aCabec,{"F1_SERIE"    ,QRY_SF2->F2_SERIE})	
	aadd(aCabec,{"F1_FORNECE"  ,"000086"})	 
	aadd(aCabec,{"F1_LOJA"     ,"01"})	 
	aadd(aCabec,{"F1_COND"     ,"001"})
	aadd(aCabec,{"F1_DTDIGIT"  ,dDataBase})
	aadd(aCabec,{"F1_TIPO"     ,"N"})	 
	aadd(aCabec,{"F1_ESPECIE"  ,"DACTE"})	 
	aadd(aCabec,{"F1_EST"      ,"SC"})	 
	//aadd(aCabec,{"F1_CHVNFE"   ,QRY_SF2->F2_CHVCONH})  
	aadd(aCabec,{"F1_ORIIMP"   ,"AGX553"})        
	aadd(aCabec,{"F1_FORMUL"   ,"N"}) 
	aadd(aCabec,{"E2_NATUREZ"   ,"999"})  
	
	conout("1")
		
	aLinha := {}	
	aadd(aLinha,{"D1_FILIAL"  ,cCodFil,Nil})		 
	aadd(aLinha,{"D1_COD"     ,"9916",Nil})      
	aadd(aLinha,{"D1_QUANT"   ,1,Nil}) 
	aadd(aLinha,{"D1_VUNIT"   ,QRY_SF2->F2_VALMERC,Nil})
	aadd(aLinha,{"D1_TOTAL"   ,QRY_SF2->F2_VALMERC,Nil})
	aadd(aLinha,{"D1_TES"     ,"062" ,Nil})         
	aadd(aLinha,{"D1_ORIIMP"  ,"AGX553" ,Nil})      
	                                                 
	aadd(aItens,aLinha)		                              
	
	
	   Begin Transaction
   lMsErroAuto := .F.
	//   MSExecAuto({|x,y| mata103(x,y)},aCabec,aItens)
MSExecAuto( {|x,y,z,w|     MATA103( x, y, z, w ) }, aCabec, aItens, 3, .F. )


   //MsExecAuto({|x,y,z,w|Mata103(x,y,z,w)},aCabec, aItens,3,.F.)

   If lMsErroAuto
      MostraErro()
   Endif   

   End Transaction
	
/*	MSExecAuto({|x,y| mata103(x,y)},aCabec,aItens)		
	If !lMsErroAuto		
		ConOut(OemToAnsi("Incluido com sucesso! ")+QRY_SF2->F2_DOC)	   
	Else	   
		MostraErro()		
		ConOut()		
	EndIf	*/
	
	ConOut(OemToAnsi("Fim  : ")+Time())
   	
	

	/*F1_EMISSAO
F1_EST
F1_BASEICM
F1_VALICM
F1_VALMERC 
F1_VALBRUT 
F1_TIPO = 'N'
F1_DTDIGIT =
F1_ESPECIE 
F1_RECBMTO
F1_CHVNFE */
                                                
/* D1_FILIAL 
 D1_COD = '9916'
 D1_UM = 'PC'
 D1_QUANT 
 D1_VUNIT
 D1_TOTAL
 D1_VALICM, 
 D1_TES = '062'
 D1_CF = '1353'
 D1_PICM = 17
 D1_CONTA = '112070001'
 D1_ITEMCTA = '11'
 D1_FORNECE = '000086'
 D1_LOJA '01'
 D1_LOCAL = '1'
 D1_DOC 
 D1_EMISSAO 
 D1_DTDIGIT 
 D1_GRUPO = '0018'
 D1_TIPO = 'N'
 D1_SERIE = 
 D1_CUSTO 
 D1_TP = 'FR'
 D1_BASEICM 
 D1_CLASFIS
 D1_ALQIMP6 
 D1_DESCRI = 'FRETE S/COMPRAS COMBUSTIVEIS  '              */
 
	dbSelectArea("QRY_SF2")
	QRY_SF2->(dbSkip())
EndDo                           


RESET ENVIRONMENT
   

Alert("fim")




Return(.T.)
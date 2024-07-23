#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX451    บAutor  ณRodrigo             บ Data ณ  03/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Lista Validade dos Produto                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGX451()

	SetPrvt("aImprime,cForn")

	aImprime := {}   
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo,listar produtos")
	cDesc2        	:= OemToAnsi("sem venda em um perํodo. ")
	cDesc3        	:= ""
	cPict         	:= ""
	titulo       	:= "Produtos Sem Venda"
	nLin         	:= 80
    cabec1  		:=	"PRODUTO             DESCRICAO                                            ARMAZEM      ENDERECO          LOTE           SALDO         VALIDADE "                                      
	cabec2       	:= ""
	imprime      	:= .T.
	aOrd 				:= ""
	lEnd           := .F.
	lAbortPrint    := .F.
	CbTxt          := ""
	limite         := 132
	tamanho        := "G"
	nomeprog       := "AGX451"
	nTipo          := 18
	aReturn        := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey       := 0
	cbtxt        	:= Space(10)
	cbcont       	:= 00
	CONTFL      	:= 01
	m_pag       	:= 01
	wnrel       	:= "AGX451"
	aRegistros  	:= {}
	cPerg		 	   := "AGX451"
	cString 	   	:= "DA1"  
	titulo  	      :="Validade Produtos"
   cCancel 	      := "***** CANCELADO PELO OPERADOR *****"
	aRegistros     := {}   
	
	AADD(aRegistros,{cPerg,"01","Validade de               ?","mv_ch1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Validade at้              ?","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Produto  de               ?","mv_ch3","C",15,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"04","Produto  at้              ?","mv_ch4","C",15,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"05","Armazem  de               ?","mv_ch5","C",02,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Armazem  at้              ?","mv_ch6","C",02,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","",""})	
	
	U_CriaPer(cPerg,aRegistros)   
	Pergunte(cPerg,.F.)
	
    wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
	    Set Filter To
	    Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	    Set Filter To
	    Return
	Endif   
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracoes de arrays                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

    cForn := ""
   
	Processa({|| GeraDados() })
     	
    RptStatus({|| RptDetail() })  

  	    
Return

Static Function GeraDados()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria expressao de filtro do usuario                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	aImprime := {}  

	/* QUERY PESQUISA   */    
	cQuery := "" 	


	cQuery := "SELECT BF_PRODUTO PRODUTO,(SELECT B1_DESC FROM " + RetSqlName("SB1") + " WHERE B1_COD = BF_PRODUTO AND B1_FILIAL =  BF_FILIAL AND " 
    cQuery += " D_E_L_E_T_ <> '*') DESCRICAO,  BF_LOCAL ARMAZEM, BF_LOCALIZ ENDERECO, BF_LOTECTL LOTE , BF_QUANT QUANTIDADE, B8_DTVALID VALIDADE "
    cQuery += " FROM  " +  RetSqlName("SBF") + " BF, " + RetSqlName("SB8") + " B8 "
	cQuery += " WHERE BF.D_E_L_E_T_ <> '*'   AND B8.D_E_L_E_T_ <> '*'   AND BF_LOTECTL <> ''   AND B8_PRODUTO = BF_PRODUTO  AND B8_LOTECTL = BF_LOTECTL "
    cQuery += " AND B8_FILIAL = BF_FILIAL    AND B8_LOCAL =  BF_LOCAL    AND BF_LOCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
    cQuery += " AND BF_PRODUTO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
    cquery += " AND B8_DTVALID BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
    cQuery += " AND BF_FILIAL = '"+ xFilial("SBF") + "' "  
    cQuery += " ORDER BY B8_DTVALID "
	
   
    cQuery := ChangeQuery(cQuery)
    If Select("MTEMP") <> 0
       dbSelectArea("MTEMP")
	   dbCloseArea()
    Endif

    TCQuery cQuery NEW ALIAS "MTEMP"
    TCSetField("MTEMP","VALIDADE","D",08,0)   

          
    dbSelectArea("MTEMP")
    dbGoTop()                   
    While !Eof()  
 	   
      	Aadd(aImprime,{MTEMP->PRODUTO,;
  					   MTEMP->DESCRICAO,;
   	   				   MTEMP->ARMAZEM,;
   		   		       MTEMP->ENDERECO,;
			   		   MTEMP->LOTE,;
   				   	   MTEMP->QUANTIDADE,;
   					   MTEMP->VALIDADE})
      DbSelectArea("MTEMP")
      MTEMP->(DbSkip())	      					
   EndDo

    If Select("MTEMP") <> 0
       dbSelectArea("MTEMP")
	   dbCloseArea()
    Endif

Return

Static Function RptDetail	
  	titulo      := titulo

	SetRegua(Len(aImprime)) //Ajusta numero de elementos da regua de relatorios    
	
	
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
	
	
	nLin 		:= 9
	nTotVol	:= 0
	nTotFat	:= 0         
	
  //  @1,000 PSAY "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
  //  nLin 		+= 1
	For I := 1 to Len(aImprime)
	   If lEnd
	      Exit
	   endif
		
	   IncRegua() //Incrementa a posicao da regua de relatorios
	   
	   if nLin > 55
	   	Roda(0,"","P") 		
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
			nLin := 9			
		EndIf
		   
		@ nLin,000 PSAY aImprime[I,1]
		@ nLin,020 PSAY aImprime[I,2]	 
    	@ nLin,073 PSAY aImprime[I,3] 
		@ nLin,086 PSAY aImprime[I,4]  
		@ nLin,104 PSAY aImprime[I,5]
		@ nLin,119 PSAY aImprime[I,6]
		@ nLin,133 PSAY aImprime[I,7]

		nLin := nLin + 1

	Next

	Set Filter To

    SetPgEject(.F.) 

  	If aReturn[5] == 1
		Set Printer To
		Commit
	   ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool   
Return
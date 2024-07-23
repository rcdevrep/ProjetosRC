#INCLUDE "rwmake.ch"    
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"         
#INCLUDE "TOPCONN.CH"



User Function DSERASA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de Variaveis                                             ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Private _cString   := "SA1"
Private _cPerg     := "DSERASA"
Private _oGeraTxt  
Private _cPath     := '', _cFile  := ''
Private _cEOL      := "CHR(13)+CHR(10)"
Private _nTotCli   := 0 
Private _nTotcRec  := 0    
Private cDtCorte   := '20191115'  

PutSx1(_cPerg, "01", "Data Inicial      ?", "" , "", "mv_ch1", "D", 8 , 0, 2, 'G',"","","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", "")     
PutSx1(_cPerg, "02", "Data Final        ?", "" , "", "mv_ch2", "D", 8 , 0, 2, 'G',"","","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", "")  
PutSx1(_cPerg, "03", "Destino           ?", "" , "", "mv_ch3", "C", 40 , 0, 2, 'G',"","","","", "mv_par03", "","", "","" ,"","","","","","","","","","","","", "","", "")   
PutSx1(_cPerg, "04", "Periodicidade da Remessa?", "" , "", "mv_ch4", "N", 1 , 0, 2, 'C',"","","","", "mv_par04", "Diario","", "","" ,"Mensal","","","","Semanal","","","","Quinzenal","","","", "","", "")   

Pergunte(_cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Montagem da tela de processamento.                                  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

@ 200,1 TO 380,600 DIALOG _oGeraTxt TITLE OemToAnsi("Gerenciamento Arquivo SERASA")
//@ 001,001 TO 50,50
@ 001,002 Say " Este programa ira gerar/conciliar arquivos com informações de clientes para o SERASA." SIZE 100,10

//@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
//@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| OkGeraTrb() }) 
//@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt) 
//@ 70,218 BUTTON TYPE 14 ACTION Processa( {|| Concilia() })   

@ 70,110 BUTTON "Parâmetros"    SIZE 38,12 PIXEL OF _oGeraTxt ACTION  Pergunte(_cPerg,.T.)  
@ 70,150 BUTTON "Gerar Arquivo" SIZE 38,12 PIXEL OF _oGeraTxt ACTION  Processa( {|| OkGeraTrb() })   
@ 70,190 BUTTON "Conciliar"     SIZE 38,12 PIXEL OF _oGeraTxt ACTION  Processa( {|| Concilia() })  
@ 70,230 BUTTON "Fechar"        SIZE 38,12 PIXEL OF _oGeraTxt ACTION  Close(_oGeraTxt) 




Activate Dialog _oGeraTxt Centered

Return
//-------------------------------------
Static Function OkGeraTrb

//_cPath     := Alltrim( mv_par01 ) + '\'
_cFile     := mv_par03   //_cPath + alltrim(mv_par02)
_cDataIni  := MV_PAR01
_cDataFim  := MV_PAR02
_cTipoMov  :=''
_nTotcRec  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Cria o arquivo texto                                                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Private _nHdl    := fCreate(alltrim(_cFile) + ".TXT")

_cEOL := CHR(13)+CHR(10)
conout('Gerando Arquivo '+ time())
If _nHdl == -1
	MsgAlert("O arquivo "+_cFile+".TXT"+" nao pode ser gerado! Verifique os parametros.","Atencao!")
	Return
Endif
//
Do case 
   case mv_par04 ==1 
       _cTipoMov := 'D'
   case mv_par04 ==2   
       _cTipoMov := 'M' 
   case mv_par04 ==3    
       _cTipoMov := 'S'
   case mv_par04 ==4    
       _cTipoMov := 'Q'   
Endcase
//   

_cTipoMov := "S"  

cQuery := "SELECT E1_CLIENTE , E1_LOJA ,A1_PRICOM,A1_CGC, A1_NOME, A1_PRICOM FROM " + RetSqlname("SE1") + " E1 (NOLOCK) INNER JOIN " + RetSqlName("SA1") + "(NOLOCK) A1 "
cQuery += " ON A1_COD = E1_CLIENTE "
cQuery += " AND A1_LOJA = E1_LOJA " 
cQuery += " WHERE ((E1_EMISSAO BETWEEN '" + DTOS(_cDataIni) + "' AND '"  + DTOS(_cDataFim) + "' AND E1_BAIXA = '' ) OR (E1_BAIXA BETWEEN '" + DTOS(_cDataIni) + "' AND '"  + DTOS(_cDataFim) + "'))"
cQuery += " AND E1.D_E_L_E_T_ <> '*' "
cQuery += "  AND A1.D_E_L_E_T_ <> '*' "
cQuery += "  AND E1.E1_TIPO = 'NF' AND E1_CLIENTE NOT IN('00368','00382')  AND A1_PESSOA = 'J' "    

cQuery += "  GROUP BY E1_CLIENTE, E1_LOJA,A1_PRICOM,A1_CGC, A1_NOME, A1_PRICOM "

cAliasQRY1 := GetNextAlias() 
   
If Select(cAliasQRY1) <> 0
	dbSelectArea(cAliasQRY1)
	dbCloseArea()
Endif
 
cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS (cAliasQRY1) 
  
 


//
// O bloco Abaixo tem como objetivo montar o arquivo com os dados do cliente
// A primeira parte gravar?o cabecalho do arquivo
_cLin := '00RELATO COMP NEGOCIOS81632093000179' + dtos( _cDataIni ) + dtos( _cDataFim ) + _cTipoMov + space(15) + space(3) + space(29) + 'V.01' + space(26) + _cEOL
//
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
//
ntotReg := 0


dbSelectArea(cAliasQRY1)
ProcRegua( lastrec() ) 
Do While !eof()

  _cLin := '01'+ (cAliasQRY1)->A1_CGC + '01' + (cAliasQRY1)->A1_PRICOM
  //
  IF  DDATABASE  - STOD((cAliasQRY1)->A1_PRICOM)  >= 365
    _cLin += '1'
  Elseif alltrim( STOD((cAliasQRY1)->A1_PRICOM ) ) <> '' .and. DDATABASE  - STOD((cAliasQRY1)->A1_PRICOM)  < 365
    _cLin += '2'    
  Elseif alltrim( STOD( (cAliasQRY1)->A1_PRICOM ) ) == ''
    _cLin += '3'        
  Endif  
  //
  _cLin += space(38) + space(34) + space(1) +  space(30) + _cEOL
  //
  If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
   	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
   		Return
   	Endif
  Endif
  //  
  //       
  
  
 
 // 9999999999999
   
	cQuery := " SELECT E1_CLIENTE,E1_LOJA, A1_CGC, E1_PREFIXO, E1_NUM , E1_PARCELA, E1_EMISSAO,E1_SALDO,E1_VENCREA,E1_BAIXA ,E1_VALOR, E1.D_E_L_E_T_ DELET FROM " + RetSqlName("SE1") 
	cQuery += " (NOLOCK) E1  INNER JOIN " + RetSqlName("SA1") +  "(NOLOCK) A1 " 
	cQuery += " ON A1_COD = E1_CLIENTE "
	cQuery += " AND A1_LOJA = E1_LOJA "
	cQuery += " WHERE ((E1_EMISSAO BETWEEN '" + DTOS(_cDataIni) + "' AND '"  + DTOS(_cDataFim) + "' AND E1_BAIXA = '') OR (E1_BAIXA BETWEEN '" + DTOS(_cDataIni) + "' AND '"  + DTOS(_cDataFim) + "'))"
	cQuery += "  AND A1.D_E_L_E_T_ <> '*' "
	cQuery += "  AND E1.E1_TIPO = 'NF' "
	//cQuery += "  AND E1.D_E_L_E_T_ = '*' "
	cQuery += "  AND E1.E1_CLIENTE = '" + (cAliasQRY1)->E1_CLIENTE + "' " 
	cQuery += "  AND E1.E1_LOJA    = '" + (cAliasQRY1)->E1_LOJA    + "' "   	
	cQuery += " ORDER BY E1_EMISSAO "                                       
	
	 cAliasQRY2 := GetNextAlias() 
   
	If Select(cAliasQRY2) <> 0
		dbSelectArea(cAliasQRY2)
		dbCloseArea()
	Endif
   
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS (cAliasQRY2) 
                                                                            	
  
  
  DbSelectArea(cAliasQRY2)
  dbgotop()
  Do while !eof()
  
         //
         If alltrim((cAliasQRY2)->DELET) <> "*" 
         	cValor  := StrZero(((cAliasQRY2)->E1_VALOR*100),13)
         Else                                                                                                  
	         cValor := "9999999999999"
		 EndIf
		  
		 
		  
         _cLin  := '01' //Id Registro
         
		 nAux := 0
		 nAux := 14 - len(alltrim((cAliasQRY2)->A1_CGC)) 
		 
		 // Data de Corte para títulos com Prefixo de 3 posições
		 If (cAliasQRY2)->E1_EMISSAO >=  cDtCorte  //Chave completa
			 cTitulo := (cAliasQRY2)->E1_PREFIXO + (cAliasQRY2)->E1_NUM + (cAliasQRY2)->E1_PARCELA 
		 Else 
			 cTitulo := alltrim((cAliasQRY2)->E1_PREFIXO) + alltrim((cAliasQRY2)->E1_NUM) + alltrim((cAliasQRY2)->E1_PARCELA) 
		 Endif 
		 nEspAux := 32 - len(alltriM(cTitulo))
		 
         _cLin  += alltrim((cAliasQRY2)->A1_CGC)  + space(nAux) //CNPJ 
		 _cLin  += '05' // Tipo de dados
		 _cLin  += space(10) //numero do titulo com 10 posicoes
		 _cLin  += (cAliasQRY2)->E1_EMISSAO //Data de Emissao  '
		 _cLin  += cValor // Valor Saldo
         _cLin  += (cAliasQRY2)->E1_VENCREA  // Data vencimento
         _cLin  += (cAliasQRY2)->E1_BAIXA   //Data Pagamento 
         _cLin  += "#D" // Numero de titulos com mais de 10 posicoes
         _cLin  += alltrim(cTitulo) + space(nEspAux) + space(1) + space(24) + space(2) + space(1) + space(1) + space(2)
         _cLin  += _cEOL
  			If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
   		   		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
   					Return
   				Endif
  			Endif
         //
         _nTotcRec ++
         dbSelectArea(cAliasQRY2)
         (cAliasQRY2)->(DbSkip())
     Enddo
  dbCloseArea(cAliasQRY2)
  // O bloco abaixo gravara o footer do arquivo.
  DbSelectArea(cAliasQRY1)
  IncProc(OemToAnsi("Lendo Cliente " + (cAliasQRY1)->E1_CLIENTE + ' - ' + Alltrim((cAliasQRY1)->A1_NOME) ))  
  //  
  (cAliasQRY1)->(DbSkip())
  ntotReg ++
  // 

Enddo    

dbCloseArea(cAliasQRY1)
//
 _cLin  := '99'+ strzero( ntotReg , 11 ) + space(44) + strzero( _nTotcRec, 11 )  + space(32) + space(30) +  _ceol
 If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
    If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
  	  Return
    Endif
 Endif
//
fClose(_nHdl)
//
conout('Finalizando Arquivo '+ time())
//alert("importou")
Return      


Static Function ImpArq()

LOCAL nLineLength := 200, nTabSize := 3, lWrap := .F. , nRec := 1
LOCAL nLines, nCurrentLine
Private cImp := .T.

	aImpArq  := {}
	cArq     := ""
 
	Aadd(aImpArq,{"INFO"      ,"C",1000,0,"C"})     //INFO
	Aadd(aImpArq,{"REC"       ,"N",9999999,0,"C"})  //REC
	Aadd(aImpArq,{"REG"       ,"C",6,0,"C"})        //REGISTRO

	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?mporto o arquivo TXT do Sped Fiscal para manipulação ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/

	If (Select("DSER") <> 0)
	dbSelectArea("DSER")
		dbCloseArea()
	Endif

	cArq := CriaTrab(aImpArq,.T.)
	dbUseArea(.T.,,cArq,"DSER",.T.,.F.)

    //*******************************************************

    nRec := 0
	Ft_fUse(mv_par03)
	ProcRegua(FT_FLastRec())
	While !FT_FEof()
//		IncProc("Aguarde Importação...")
		IncProc(nRec)
		RecLock("DSER",.T.)
			DSER->INFO := FT_FReadLn()
			DSER->REC  := nRec
			DSER->REG  := SUBSTR(FT_FReadLn() ,1,2)
		MsUnLock()
		conout('dserasa - linha - '+ alltrim(str(nRec))) 
		FT_FSkip()

		nRec++
	EndDo                 	
	FT_fUse()

	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?im Importação?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/
	cont := 0
	dbSelectArea("DSER")
	dbgotop()
	do while !eof() 
	   cont++
	   DSER->(dbskip())
	enddo


Return()          



Static Function TratArq()

lRet := .t.   
cDataHead := ""

dbSelectArea("DSER")
dbGoTop()
Do While !eof()   
	If SUBSTR(DSER->INFO,1,2) == "00" .and. SUBSTR(DSER->INFO,37,8) <> "CONCILIA"
		Alert("Arquivo não é de conciliação. Verifique.") 
		lRet := .f.
		exit 
	Endif    
	
	If SUBSTR(DSER->INFO,1,2) == "00" 
		cDataHead :=	SUBSTR(DSER->INFO,45,8)
			
	EndIf

	cPref := ""
	cNum  := ""
	cParc := ""
	cTitAux := ""
	cPrefNovo := ""
	cNumNovo  := ""//substr(cTitAux,6,9) 
	cParcNovo := ""//substr(cTitAux,15,1) 	

	If SUBSTR(DSER->INFO,1,2) == "01"      
		
		If alltrim(SUBSTR(DSER->INFO,68,32)) == ""  
			cTitAux := substr(DSER->INFO,19,10)   
			cPref := substr(cTitAux,1,3)//Mantido 3 casas devido que com 5 casas ultrapassa
			//10 caracteres caindo sempre no pr?imo IF
			cNum  := substr(cTitAux,4,6) 
			cParc := substr(cTitAux,10,1) 		
		EndIf
		If alltrim(SUBSTR(DSER->INFO,68,32)) <> ""  
			cTitAux := substr(DSER->INFO,68,32)   
			cPref := substr(cTitAux,1,3)
			cNum  := substr(cTitAux,4,9) 
			cParc := substr(cTitAux,13,1) 	
			
			//Vari?eis para t?ulos com prefixo de 5 posições
			cPrefNovo := substr(cTitAux,1,5)
			cNumNovo  := substr(cTitAux,6,9)
			cParcNovo := substr(cTitAux,15,1)

		EndIf      


		//Busco Informacoes do titulo para ver se houve pagamento.    
		cQuery := ""
		cQuery := "SELECT E1_BAIXA FROM " + RetSqlName("SE1")+"	(NOLOCK)" 
		cQuery += " WHERE ( "
		cQuery += "   ( E1_EMISSAO < '"+cDtCorte+"' AND E1_PREFIXO = '" + cPref + "' " 
		cQuery += "   AND E1_NUM = '" + cNum + "' " 
		cQuery += "   AND E1_PARCELA = '" + cParc + "' ) "
		iF alltrim(cNumNovo) <> ''
			cQuery += "  OR  ( E1_EMISSAO >= '"+cDtCorte+"' AND E1_PREFIXO = '" + cPrefNovo + "' " 
			cQuery += "   AND E1_NUM = '" + cNumNovo + "' " 
			cQuery += "   AND E1_PARCELA = '" + cParcNovo + "' ) "
		Endif
		cQuery += "   ) "
		cQuery += "   AND E1_TIPO = 'NF'"   
	 	cQuery += "   AND E1_BAIXA <= '" + cDataHead + "' "   
		cQuery += "   AND E1_BAIXA <> '' " 
		cQuery += "   AND D_E_L_E_T_ <> '*' "    
		

		conout(cPref +' - ' + cNum )
		cAliasQRY1 := GetNextAlias() 
   
		If Select(cAliasQRY1) <> 0
			dbSelectArea(cAliasQRY1)
			dbCloseArea()
		Endif
   
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS (cAliasQRY1)             
		
  		cDataBaixa := ""
		
		dbSelectArea(cAliasQRY1)
		dbgotop()
	
		Do While !eof()	
		conout('Atualizou Titulo '+ cPref +' - ' + cNum )   
	  		cDataBaixa := (cAliasQRY1)->E1_BAIXA
   			(cAliasQRY1)->(dbskip())
	
				   		
		EndDo 
		
		dbSelectArea(cAliasQRY1)
		dbCloseArea()  
		
	 	If alltrim(cDataBaixa) == "" 
			cDataBaixa := space(8)	
  		EndIf
  		
	
		cUtil := ""
	
		cUtil := substr(DSER->INFO,01,57) + cDataBaixa + substr(DSER->INFO,66,61)   
		
		RecLock("DSER",.f.)
			DSER->INFO := cUtil
		MsUnlock()
	
			
	EndIf
	

	 
	dbSelectArea("DSER")	   
    DSER->(dbSkip())
EndDO


Return(lRet)

                   
Static Function Concilia()  
	
	If !FILE(mv_par03)
		Alert("Arquivo não encontrado!")
		Return()
	EndIf
	conout('Iniciando Conciliacao '+ time())
	ImpArq() // Importo arquivo conciliacao serasa 

	
	If !TratArq() // Trato arquivo importado
		return() //nao eh arquivo de concilia?o
	EndIf
	          
	GeraArq()
	conout('Finalizando  Conciliacao '+ time())
	//alert("importou")


Return()      

Static Function GeraArq()

	Local nCont    := ""
	Local nStatus1 := ""

    nStatus1 := frename(alltrim(mv_par03) , alltrim(mv_par03) + "_old" )
    IF nStatus1 == -1
       MsgStop('Falha na operação 1 : FError '+str(ferror(),4))
    Endif

   	cArquivo := ALLTRIM(mv_par03)  
	nHandle  := 0

	If !File(cArquivo)
		nHandle := MSFCreate(cArquivo)
	Else
		fErase(cArquivo)
		nHandle := MSFCreate(cArquivo)
	Endif
//    alert("entrou no imparq")
    cLinha := ""
 	dbSelectArea("DSER")
	dbgotop()
	While !Eof()
		cLinha := ALLTRIM(DSER->INFO) + chr(13)+chr(10)
		FWrite(nHandle,cLinha,Len(cLinha))
	    DSER->(dbskip())
	EndDo

	fClose(nHandle)

Return()




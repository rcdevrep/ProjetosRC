#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} XAG0096
Rotina para realizar importação clientes atraves de uma planilha,onde o cabeçalho 
deverá ser obrigatoriamente a primeira linha
@author Leandro Spiller 
@since 05/12/2022
@version 1.0
/*/
User Function XAG0096()

	Local aRet	   	 := {}
	Local aDados	 := {}
	Local aPergs  	 := {}
   	Local cPath		 := PadR("",150)
    Private cLog     := ""
    Private cDirTemp  := AllTrim(GetTempPath())
	Private cDataHora := 'LOG_CLIENTES_'+dtos(dDatabase) +'_' +STRTRAN( time(),':','' ) 
    Private  cAtivo  := ""
    Private  cTipo  := ""

	AAdd(aPergs ,{6,OEMToANSI("Arquivo de Origem  (se vazio irá        criar um arquivo base)"),cPath,"",,"", 90 ,.F.,"Excel(*.xls) |*.xls |","",GETF_LOCALHARD})
    AAdd(aPergs, {2, "Importar como Ativo?",      cAtivo, {"N=Não","S=Sim" },    80, ".T.", .F.})// MV_PAR04
    AAdd(aPergs, {2, "Tipo?",      cAtivo, {"C=Clientes","R=Regras_desconto" },    80, ".T.", .F.})// MV_PAR04
    
   	If ParamBox(aPergs ,OEMToANSI("Importar-"),aRet)
   	   	cArq := SubStr(aRet[1],RAt("\",aRet[1]) + 1,(RAt(".",aRet[1]) - RAt("\",aRet[1]) - 1))
		cOrigem := Substr(aRet[1],1,RAt("\",aRet[1]))
        cAtivo  := aRet[2]
        cTipo   := aRet[3]

    Else
   	    MsgAlert("Processo cancelado.",AllTrim(FunName()))
   	    Return
   	EndIf
   	
    If cArq == '' 
        If  cTipo == 'C'
            If MsgYesNo("deseja gerar arquivo Base vazio?", "Responda")
                cArqBase := 'A1_NOME;A1_NREDUZ;A1_CGC;A1_INSCR;A1_TIPO;A1_HISOBS;A1_XBOLETO;A1_OBS;A1_COMPLEM;A1_END;'
                cArqBase += 'A1_BAIRRO;A1_CEP;A1_MUN ;A1_EST;A1_CONTATO;A1_DDD;A1_TEL;A1_EMAIL;A1_LC;A1_RISCO ;A1_EMAIL2'
                cArqBase += ';A1_CNAE;A1_ATIVIDA;A1_NATUREZ;A1_TPFRET;A1_CODPAIS;A1_PAIS;A1_TRANSP;A1_GRPVEN;A1_MAXDESC;'
                cArqBase += 'A1_BLOQ;A1_ARMAZEM;A1_XARARLA'
                
                MemoWrite( cDirTemp+cDataHora+".CSV", cArqBase )             

                If !ApOleClient("MsExcel")                     	
                    MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
                    Return	
                EndIf
                
                oExcelApp:= MsExcel():New()
                oExcelApp:WorkBooks:Open(cDirTemp+cDataHora+".CSV")//cArqTrbex+".XLS")
                oExcelApp:SetVisible(.T.)                       
            Endif
        Else 
            If MsgYesNo("deseja gerar arquivo Base vazio?", "Responda")
                cArqBase := "ACO_FILIAL;ACO_CODREG;ACO_DESCRI;ACO_CODCLI;ACO_LOJA;ACO_CODTAB;ACO_CONDPG;ACO_FORMPG;ACO_FAIXA;ACO_MOEDA;ACO_PERDES;"
                cArqBase += "ACO_CFAIXA;ACO_TPHORA;ACO_HORADE;ACO_HORATE;ACO_DATDE;ACO_DATATE;ACO_PROMOC;ACO_GRPVEN;ACO_DESCPR;ACO_VLRDES;ACO_MSBLQL;ACP_FILIAL;"
                cArqBase += "ACP_CODREG;ACP_ITEM;ACP_CODPRO;ACP_GRUPO;ACP_PERDES;ACP_PRECO;ACP_FAIXA;ACP_CFAIXA;ACP_DESMAX;ACP_COMIS;ACP_COMIS2;ACP_COMIS3;ACP_PROVEL;"
                cArqBase += "ACP_PRONOV;ACP_ITEMGR;ACP_VLRDES;ACP_TPDESC;ACP_XPRCAN;ACP_XDTPRC;ACP_XHRPRC;ACP_XFINTR"
                
                MemoWrite( cDirTemp+cDataHora+".CSV", cArqBase )             

                If !ApOleClient("MsExcel")                     	
                    MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
                    Return	
                EndIf
                
                oExcelApp:= MsExcel():New()
                oExcelApp:WorkBooks:Open(cDirTemp+cDataHora+".CSV")//cArqTrbex+".XLS")
                oExcelApp:SetVisible(.T.)

            Endif
        Endif 
        
         Return 
    Endif 


// 	Coleta os dados da planilha.
	aDados := U_XLS2ARR(cArq,cOrigem,0,.F.)

// Valida se o array está vazio.   
   	If !Empty(aDados)
        If substr(aDados[1][1],1,3) == 'A1_' .or. cTipo = 'C'
		    Processa({| | ImportaSA1( aDados)},"Importando Clientes...") 
        ElseIF cTipo = 'R'
            Processa({| | ImportaGEN( aDados)},"Importando ...") 
        Endif 
		//ImportaDados(aDados)
	Else
        Alert("Planilha vazia ou arquivo invalido!")
    EndIf

Return

//Realiza a Importação das informações.
Static Function ImportaGEN(aDados)
	
   Local i := 0 
   Local j := 0 
   Local aCabecalho   := {}
   Local cAlias       := ""
   
  
    //Varre dados para criar cabecalho[campo],[tipo],[tamanho],[decimal]
    For i := 1 to len(aDados[1])
        
        If Alltrim(cAlias) == ""
            cAlias := GetSx3Cache(alltrim(adados[1][i]),'X3_ARQUIVO')
        Endif 

        AADD(aCabecalho, { ;
            alltrim(adados[1][i]) ,;
            GetSx3Cache(alltrim(adados[1][i]),'X3_TIPO'),;
            GetSx3Cache(alltrim(adados[1][i]),"X3_TAMANHO"),;
            GetSx3Cache(alltrim(adados[1][i]),"X3_DECIMAL"),;
            GetSx3Cache(alltrim(adados[1][i]),"X3_ARQUIVO");
             })    
             
    Next i 
    
   
    //Valida se todos os campos são válidos
    For i := 1 to len(aCabecalho)
        If Empty(alltrim(acabecalho[i][1])) .or. Empty(alltrim(acabecalho[i][2])) .or. ; 
                 Empty(acabecalho[i][3]) 
            alert('Campo invalido: '+alltrim(acabecalho[i][1]) + ', corrija o arquivo!')
            return
        Endif 
    Next i 


    cCodLoja := ""
    //Varro Linha
    For i := 2 to len(aDados) 
        //CONOUT(I)

        If cCodLoja <> aDados[i][4] + aDados[i][5] + aDados[i][7] 
            cCodLoja := aDados[i][4] + aDados[i][5] + aDados[i][7] 
            cCodReg := GetSx8Num("ACO","ACO_CODREG")  
            lRepetiu := .F.
        else
            //conout('Repetiu '+aDados[i][4] + aDados[i][5] )
            lRepetiu := .T.
        Endif 

        if aDados[i][4] == "05470"
               cteste := ""
        endif 
        // CONOUT(cCodReg)                                                                                                
        
        //Cria novo registro 
        If !lRepetiu
            Reclock(cAlias,.T.)
            
                //Inicio a Gravacao 
                For j := 1 to 22//len(acabecalho) .and. acabecalho[j][4] == 'ACO'
                    If alltrim(valtype(aDados[i][j])) == alltrim(acabecalho[j][2])
                        &(alltrim(acabecalho[j][1])) := aDados[i][j]
                    Elseif  alltrim(valtype(aDados[i][j])) == 'C'  .and. alltrim(acabecalho[j][2]) == 'N'
                        &(alltrim(acabecalho[j][1])) := val(STRTRAN(aDados[i][j],',','.'))
                    Elseif  alltrim(valtype(aDados[i][j])) == 'N'  .and. alltrim(acabecalho[j][2]) == 'C'
                        &(alltrim(acabecalho[j][1])) := alltrim(str(aDados[i][j]))
                    Endif 
                    //CONOUT('REGISTRO ACO ['+ alltrim(STR(I))+']['+alltrim(STR(J))+'] '  + alltrim(acabecalho[j][1]))
                Next j 
                
                (cAlias)->ACO_CODREG := cCodReg
            (cAlias)->(Msunlock())
        Endif 
        ConfirmSx8()

        //nInicio := j
        //Cria novo registro 
        Reclock('ACP',.T.)
         
            //Inicio a Gravacao 
            For j := 23 to len(acabecalho) 
                If alltrim(valtype(aDados[i][j])) == alltrim(acabecalho[j][2])
                    &(alltrim(acabecalho[j][1])) := aDados[i][j]
                Elseif  alltrim(valtype(aDados[i][j])) == 'C'  .and. alltrim(acabecalho[j][2]) == 'N'
                    &(alltrim(acabecalho[j][1])) := val(STRTRAN(aDados[i][j],',','.'))
                Elseif  alltrim(valtype(aDados[i][j])) == 'N'  .and. alltrim(acabecalho[j][2]) == 'C'
                    &(alltrim(acabecalho[j][1])) := alltrim(str(aDados[i][j]))
                Endif 
                //CONOUT('REGISTRO ACO ['+ alltrim(STR(I))+']['+alltrim(STR(J))+'] ' + alltrim(acabecalho[j][1]))
            Next j 
            ACP_CODREG := cCodReg

        ('ACP')->(Msunlock())


    Next i 


	
	/*AAdd(aErros,{cProd,"Endereço "+AllTrim(cLocaliz)+" não encontrado na tabela SBE."}) 
	If Len(aErros) > 0
		DEFINE MSDIALOG oDlg TITLE "Erros Encontrados" FROM 0,0 TO 240,500 PIXEL
		@ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER "Produto", "Erro";
				SIZE 230,095 OF oDlg PIXEL ON dblClick(oLbx:Refresh()) SCROLL
				oLbx:SetArray(aErros)
				oLbx:bLine := {|| { aErros[oLbx:nAt,1],aErros[oLbx:nAt,2]}}
		DEFINE SBUTTON FROM 107,213 TYPE 1 OF oDlg ACTION oDlg:End() ENABLE
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf                            

	MsgInfo("Documento Processado!",AllTrim(FunName()))*/

    cMsg := "Verifique log em TXT "
    If Empty(cLog)
        cLog := "Registros processados com sucesso!"  
        cMsg := "Tudo ok!"
    Endif 
 
        MemoWrite( cDirTemp+cDataHora+".txt", clog ) 
    // __CopyFIle(cArq , AllTrim(GetTempPath())+cArq)  
        shellExecute( "Open", "C:\Windows\System32\notepad.exe", cDataHora+".txt", cDirTemp, 1 )
        
    MsgInfo("Documento Processado!","")
    
 	
Return	  


//Realiza a Importação das informações.
Static Function ImportaSA1(aDados)
	
   Local i := 0 
   Local j := 0 
   Local aCabecalho   := {}
   Local nPosCNPJ     := 0 
   Local nPosPessoa   := 0 
   Local nPosCodMun   := 0 
   Local nPosEst      := 0 
   Local nPosMun      := 0
   Local nPosMunc     := 0 
   

  
    //Varre dados para criar cabecalho[campo],[tipo],[tamanho],[decimal]
    For i := 1 to len(aDados[1])
        AADD(aCabecalho, { ;
            alltrim(adados[1][i]) ,;
            GetSx3Cache(alltrim(adados[1][i]),'X3_TIPO'),;
            GetSx3Cache(alltrim(adados[1][i]),"X3_TAMANHO"),;
            GetSx3Cache(alltrim(adados[1][i]),"X3_DECIMAL");
             })
        If alltrim(adados[1][i]) == 'A1_CGC'
            nPosCNPJ := i
        Endif 
        If alltrim(adados[1][i]) == 'A1_PESSOA'
            NposPessoa := i
        Endif 
        If alltrim(adados[1][i]) == 'A1_COD_MUN'
            nPosCodMun := i
        Endif 
        If alltrim(adados[1][i]) == 'A1_EST'
            nPosEst := i
        Endif 
        If alltrim(adados[1][i]) == 'A1_MUN'
            nPosMun := i
        Endif 
        If alltrim(adados[1][i]) == 'A1_MUNC'
            nPosMunc := i
        Endif 

        
        
    Next i 
    
    If nPosCNPJ == 0 
        alert('Campo obrigatorio: A1_CGC')
        Return
    Endif 

    If nPosEst == 0 
         alert('Campo obrigatorio: A1_EST')
        Return
    Endif 

    //Valida se todos os campos são válidos
    For i := 1 to len(aCabecalho)
        If Empty(alltrim(acabecalho[i][1])) .or. Empty(alltrim(acabecalho[i][2])) .or. ; 
                 Empty(acabecalho[i][3]) 
            alert('Campo invalido: '+alltrim(acabecalho[i][1]) + ', corrija o arquivo!')
            return
        Endif 
    Next i 


    //Varro Linha
    For i := 2 to len(aDados)

        Dbselectarea('SA1')
        DbseTORDER(3)
        If Dbseek(xfilial('SA1') + Alltrim(aDados[i][nPosCNPJ]))
            cLog += 'AVISO - Cliente ja existente na base:  '+ SA1->A1_CGC+' - '+SA1->A1_NOME + chr(10) 
            loop
        Endif 

        If NposPessoa > 0 
            cTpPessoa := IIf(len(aDados[i][NposPessoa]) > 11, "J", "F")
        Else
            cTpPessoa := IIf(len(aDados[i][nPosCNPJ]) > 11, "J", "F")
        Endif 

        If nPosCodMun > 0 
            cCodMun := alltrim(aDados[i][nPosCodMun])
            dbselectarea('CC2')
            dbsetorder(3)
            dbseek(xfilial('CC2') +alltrim(aDados[i][nPosEst])+ alltrim(cCodMun))
            cCodANP := CC2->CC2_CODANP
        Else
            dbselectarea('CC2')
            dbsetorder(4)
            If Dbseek(xfilial('CC2') +alltrim(aDados[i][nPosEst]) + alltrim(aDados[i][nPosMun])  )
                cCodMun := CC2->CC2_CODMUN//alltrim(aDados[i][nPosCodMun])
                cCodANP := CC2->CC2_CODANP
            Else
                cLog += 'ERRO  - Nome municipio invalido ou nao contido na base:  '+ Alltrim(aDados[i][nPosCNPJ])+' - '+alltrim(aDados[i][nPosMun]) + chr(13) 
                Loop
            Endif 

        Endif 

   		If (cTpPessoa == "F")
   			cCodNovo   := SA1NovoCod()
	 		cLojaNovo  := "01"
		Else
			cCGCBase := SubStr(aDados[i][nPosCNPJ], 1, 8)
			aUltCdLj := SA1UltLoja(cCGCBase)
       	
        	If (Len(aUltCdLj) == 2)
				cCodNovo   := aUltCdLj[1]
				cLojaNovo  := aUltCdLj[2]
   		    Else
				cCodNovo   := SA1NovoCod()
   				cLojaNovo  := "01"
			EndIf
		EndIf  

        //Cria novo registro 
        Reclock('SA1',.T.)
            A1_COD     := cCodNovo
            A1_LOJA    := cLojaNovo
            A1_ORIIMP  := 'XAG0096'
            A1_PESSOA  := cTpPessoa
            A1_COD_MUN := cCodMun
            A1_POSTOAG := '2'
            A1_MUN_ANP  := cCodANP
            If cAtivo == 'S'
                A1_MSBLQL := '2'
            Else
                A1_MSBLQL := '1'
            Endif 
            //Inicio a Gravacao 
            For j := 1 to len(acabecalho)
                If alltrim(valtype(aDados[i][j])) == alltrim(acabecalho[j][2])
                    &(alltrim(acabecalho[j][1])) := aDados[i][j]
                Elseif  alltrim(valtype(aDados[i][j])) == 'C'  .and. alltrim(acabecalho[j][2]) == 'N'
                    &(alltrim(acabecalho[j][1])) := val(aDados[i][j])
                Elseif  alltrim(valtype(aDados[i][j])) == 'N'  .and. alltrim(acabecalho[j][2]) == 'C'
                    &(alltrim(acabecalho[j][1])) := alltrim(str(aDados[i][j]))
                Endif 
            Next j 

            //Caso não tenha preenchido dados de cobrança, preenche com o endereço
            If nPosMunc == 0 
                A1_CEPC   := SA1->A1_CEP
                A1_MUNC   := SA1->A1_MUN
                A1_ESTC   := SA1->A1_EST
                A1_BAICOB := SA1->A1_BAIRRO
                A1_CEPCOB := SA1->A1_CEP
                A1_MUNCOB := SA1->A1_MUN 
                A1_ESTCOB := SA1->A1_EST
            Endif

            if SA1->A1_TIPO == 'F'
               	A1_GRPTRIB := '999'
            Else
	            A1_GRPTRIB := '001'
            Endif

            A1_PABCB = SA1->A1_PAIS
            A1_CONSER = '1'

            If Empty(SA1->A1_ESTE) 
                A1_ESTE    := A1_EST
            Endif 
        SA1->(Msunlock())

    Next i 


	
	/*AAdd(aErros,{cProd,"Endereço "+AllTrim(cLocaliz)+" não encontrado na tabela SBE."}) 
	If Len(aErros) > 0
		DEFINE MSDIALOG oDlg TITLE "Erros Encontrados" FROM 0,0 TO 240,500 PIXEL
		@ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER "Produto", "Erro";
				SIZE 230,095 OF oDlg PIXEL ON dblClick(oLbx:Refresh()) SCROLL
				oLbx:SetArray(aErros)
				oLbx:bLine := {|| { aErros[oLbx:nAt,1],aErros[oLbx:nAt,2]}}
		DEFINE SBUTTON FROM 107,213 TYPE 1 OF oDlg ACTION oDlg:End() ENABLE
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf                            

	MsgInfo("Documento Processado!",AllTrim(FunName()))*/

    cMsg := "Verifique log em TXT "
    If Empty(cLog)
        cLog := "Registros processados com sucesso!"  
        cMsg := "Tudo ok!"
    Endif 
 
    MemoWrite( cDirTemp+cDataHora+".txt", clog ) 
   // __CopyFIle(cArq , AllTrim(GetTempPath())+cArq)  
    shellExecute( "Open", "C:\Windows\System32\notepad.exe", cDataHora+".txt", cDirTemp, 1 )
    
    MsgInfo("Documento Processado!","")
    
 	
Return	           

//Valida ultima Loja 
Static Function SA1UltLoja(cCGCBase)

	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local cLoja     := ""
	Local aRet      := {}

	cQuery += " SELECT SA1.A1_COD, "
	cQuery += " MAX(SA1.A1_LOJA) AS A1_LOJA "
	cQuery += " FROM " + RetSQLName("SA1") + " SA1 (NOLOCK) "
	cQuery += " WHERE SA1.D_E_L_E_T_ = '' "
	cQuery += " AND   SA1.A1_CGC LIKE '" + cCGCBase + "%' "
	cQuery += " GROUP BY SA1.A1_COD "

	TCQuery cQuery NEW ALIAS (cAliasQry)

	If !Empty((cAliasQry)->(A1_COD)) .And. !Empty((cAliasQry)->(A1_LOJA))
		aAdd(aRet, (cAliasQry)->(A1_COD))

		cLoja := Soma1((cAliasQry)->(A1_LOJA))
		aAdd(aRet, cLoja)
	EndIf

Return(aRet)
              

//Pega proximo código válido
Static Function SA1NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	cX3_Relacao := GetSx3Cache("A1_COD", "X3_RELACAO")

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SA1", "A1_COD")
		EndIf

		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
		lJaExiste := SA1->(DbSeek(xFilial("SA1")+cCodNovo))
	End

Return(cCodNovo)

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"

//-------------------------------------------+
// Data : 28/11/2016  Autor: Leandro Spiller |
//-------------------------------------------+
//   Descrição: Integração de Notas de    	 |
//   Saída Protheus x AutoSystem        	 |
//-------------------------------------------+
User Function SLAAGR15()

	Private	cCadastro := "Importação de Saídas"
	Private cFilAte   := ""
	Private cPessoa   := ""
	Private cFilDe    := ""
	Private cParEspec := ""
	Private cEmpresa  := ""
	Private cLojaCli  := ""
	Private cCodCli   := ""
	Private cNOMECLI  := ""
	Private cEstFor   := ""
	Private _cNome    := StrTran(DTOC(Date()),"/","_")+"-"+StrTran(time(),":","")
	Private nHandle   := FCREATE("log_autosystem\SLAAGR15_"+_cNome+".txt")
	Private nCont     := 0

	Private oXagCon   := XagConexao():New()

	Private lCliente  := .T.
	Private lProduto  := .T.
	Private lItemnf   := .T.
	Private lNFiscal  := .T.
	Private lDupli    := .T.
	Private lCliente1 := .T.
	Private lProduto1 := .T.
	Private lItemnf1  := .T.
	Private lNFiscal1 := .T.
	Private lDupli1   := .T.
	Private cFilIN    := ""
	Private aRotina   := { { "Importar" ,"U_AGR15IMP()" , 0, 1},;
	              	       { "Legenda"  ,"U_AGR15LEG()" , 0, 3}}//{ "Legenda"  ," "           , 0, 3}}

	Private aCores := {{"SLA15->EXISTE <> 'E'.AND. ALLTRIM(SLA15->CDCLIENTE)<> ''",'BR_VERDE'    } ,;
	         		   {"SLA15->EXISTE = 'E' "	 			          ,'BR_AZUL'   },;
	                   {"ALLTRIM(SLA15->CDCLIENTE) = ''   "		  ,'BR_LARANJA'   }}

	If cEmpAnt <> '20' .AND. cEmpAnt <> '13'.AND. cEmpAnt <> '17' .AND. cEmpAnt <> '21' .AND. cEmpAnt <> '24' .AND. cEmpAnt <> '25'.AND. cEmpAnt <> '27'.AND. cEmpAnt <> '44'.AND. cEmpAnt <> '51'.AND. cEmpAnt <> '52' .AND. cEmpAnt <> '53'.AND. cEmpAnt <> '57'
	   Alert("Atenção! Esta rotina está disponivel somente para as Empresas 13, 17, 20, 21, 24, 25, 27, 44, 51, 52, 53, 57!")
	   Return()
	EndIf

	cPerg := "SLAAGR15"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Emissão de       ?","mv_ch1","D",08,0,0,"G","","mv_par01" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Emissão até      ?","mv_ch2","D",08,0,0,"G","","mv_par02" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Num. NF de       ?","mv_ch3","C",09,0,0,"G","","mv_par03" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Num. NF até      ?","mv_ch4","C",09,0,0,"G","","mv_par04" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Série NF de      ?","mv_ch5","C",03,0,0,"G","","mv_par05" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Série NF até     ?","mv_ch6","C",03,0,0,"G","","mv_par06" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Filial de        ?","mv_ch7","C",02,0,0,"G","","mv_par07" ,"","","","","","","","","","","","","","","SM0"})
	AADD(aRegistros,{cPerg,"08","Filial até       ?","mv_ch8","C",02,0,0,"G","","mv_par08" ,"","","","","","","","","","","","","","","SM0"})
	//AADD(aRegistros,{cPerg,"06","CLIENTE       ?","mv_ch6","C",09,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SA2"})

	//- Emissão de:- Emissão até:- Nota fiscal de: - Nota Fiscal Até:- Filial de :- Filial ate:

	U_CriaPer(cPerg,aRegistros)

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	//Caso utilize letrar fixa maximo numérico
	If MV_PAR04 > '999999999'
		MV_PAR04 := '999999999'
	Endif

	aCampos  := {}
	aTam     := {}
	cArqTrab := ""

	aTam:=TamSX3("F2_FILIAL");AADD(aCampos,{"FILIAL","C",aTam[1],aTam[2] } )
	aTam:=TamSX3("A1_NOME");AADD(aCampos,{"NOMECLI","C",aTam[1],aTam[2] } )
	aTam:=TamSX3("F2_DOC");AADD(aCampos,{"DOCUMENTO","C",aTam[1],aTam[2] } )
	aTam:=TamSX3("F2_SERIE");AADD(aCampos,{"SERIE","C",aTam[1],aTam[2] } )
	aTam:=TamSX3("F2_CLIENTE");AADD(aCampos,{"CLIENTE","C",15,0 } )
	aTam:=TamSX3("F2_EMISSAO");AADD(aCampos,{"EMISSAO","D",8,0 } )
	aTam:=TamSX3("F2_TIPO");AADD(aCampos,{"TIPO","C",aTam[1],aTam[2] } )
	aTam:=TamSX3("F2_CGC");AADD(aCampos,{"CGC","C",20,0} )
	aTam:=TamSX3("F2_VALMERC");AADD(aCampos,{"TOTAL","N",aTam[1],aTam[2] } )
	aTam:=TamSX3("F2_CLIENTE");AADD(aCampos,{"CDCLIENTE","C",15,0 } )
	aTam:=TamSX3("F2_LOJA");AADD(aCampos,{"CLIENTELJ","C",15,0 } )
	aTam:=TamSX3("F2_TIPO");AADD(aCampos,{"FINALID","C",aTam[1],aTam[2], "" } )
	AADD(aCampos,{"EXISTE","C",1,0, "" } )
	AADD(aCampos,{"CNPJFIL","C",20,0,""} )

	cArqTrab:= CriaTrab(aCampos,.T.)

	If Select("SLA15") <> 0
		dbSelectArea("SLA15")
	   	dbCloseArea()
	Endif

	dbUseArea(.T.,,cArqTrab,"SLA15",.T.,.F.)
	Indregua("SLA15",cArqTrab,"DOCUMENTO",,,OemToAnsi("Selecionando Registros..."))

	Processa({|| U_15BUSCA()}, "Buscando Info. no Autosystem,Aguarde...")

	//U_CriaSLA()
	aCampBrw:= {}
	aTam:=TamSX3("F2_FILIAL");AADD(aCampBrw,{"Filial", "FILIAL", "C",2,0, "" } )
	aTam:=TamSX3("F2_EMISSAO");AADD(aCampBrw,{"Emissão", "EMISSAO", "D",8,0, "" } )
	aTam:=TamSX3("F2_DOC");AADD(aCampBrw,{"Nota Fiscal", "DOCUMENTO","C",aTam[1],aTam[2], "" } )
	aTam:=TamSX3("F2_SERIE");AADD(aCampBrw,{"Serie", "SERIE","C",aTam[1],aTam[2], "" } )
	aTam:=TamSX3("F2_CLIENTE");AADD(aCampBrw,{"CLIENTE (Grid)", "CLIENTE","C",15,0, "" } )
	aTam:=TamSX3("F2_TIPO");AADD(aCampBrw,{"Tipo", "TIPO","C",aTam[1],aTam[2], "" } )
	aTam:=TamSX3("A1_NOME");AADD(aCampBrw,{"Nome CLIENTE", "NOMECLI","C",aTam[1],aTam[2], "" } )
	aTam:=TamSX3("F2_CGC");AADD(aCampBrw,{"CNPJ/CPF", "CGC","C",15,0, "" } )
	aTam:=TamSX3("F2_VALMERC");AADD(aCampBrw,{"Total", "TOTAL","C",aTam[1],aTam[2], "@E 999,999,999.99" } )
	aTam:=TamSX3("F2_CLIENTE");AADD(aCampBrw,{"CLIENTE (Microsiga)", "CDCLIENTE","C",15,0, "" } )
	aTam:=TamSX3("F2_LOJA");AADD(aCampBrw,{"Loja (Microsiga)", "CLIENTELJ","C",15,0, "" } )
	aTam:=TamSX3("F2_TIPO");AADD(aCampBrw,{"Finalidade", "FINALID","C",aTam[1],aTam[2], "" } )
	AADD(aCampBrw,{"Ja_Existe","EXISTE","C",1,0, "" } )
	AADD(aCampBrw,{"Cnpj_Fil","CNPJFIL","C",20,0,""} )

	dbSelectArea("SLA15")
	dbSetOrder(1)
	mBrowse(6,1,22,75,"SLA15",aCampBrw,,,,,aCores)

Return()


//--------------------------------------------+
//    Busca dados no Sistema AutoSystem       |
//--------------------------------------------+
User Function 15BUSCA()

	Local cQuery      := ""
	Local lRet        := .T.
	Private _cXFilial := ""
	Private lExiste   := .F.
	Private cA2PJ     := ""
	Private cLoja     := ""
	Private cCliente  := ""
	Private cNomeCli  := ""
	Private lValCGC   := .F.

	If nHandle = -1
		Conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	Else
		FWrite(nHandle, Time() + CRLF)
	Endif

	If (!oXagCon:ConecATS())
		MsgAlert("Não foi possivel conectar ao Autosytem ...")
		FWrite(nHandle, "SLAARG15 - Não foi possivel conectar ao Autosystem." + CRLF)
		Return
	Else
		FWrite(nHandle, "SLAAGR15 - Conexão com o servidor estabelecida." + CRLF)

		oXagCon:ConecPRT()

		cFilIN := ""
		DbSelectArea("SM0")
		DbGotop()
		While !Eof()
			If SM0->M0_CODIGO == cEmpAnt
				If SM0->M0_CODFIL >= Alltrim(MV_PAR07)  ;
					.and. SM0->M0_CODFIL <= Alltrim(MV_PAR08)
					cFilIN += "'"+Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")+"',"
					//cFilIN += "'"+ALLTRIM(SM0->M0_CGC)+"',"
				EndIf
			EndIf
			DbSelectArea("SM0")
			DbSkip()
		EndDo

		//Retira ',' no final do filtro
		cFilIN := Substr(cFilIN,1,len(cFilIN)-1)

		oXagCon:ConecATS()

		cTRF2 := " select nf.empresa as EMPRESA, "
        cTRF2 += "        case substring(nf.cfop, 3, length(nf.cfop)) "
        cTRF2 += "           when '927' then nf.empresa               "
        cTRF2 += "           else nf.pessoa                           "
        cTRF2 += "        end AS PESSOA,  		                      "
		cTRF2 += "        empresa.grid AS EMPGRID, "
        cTRF2 += "        case substring(nf.cfop, 3, length(nf.cfop)) "
        cTRF2 += "           when '927' then empresa.grid             "
        cTRF2 += "           else pessoa.grid                         "
        cTRF2 += "        end AS PESSOAGRID,		                  "
		cTRF2 += "        nf.numero_nota   as F2_DOC, cast(nf.serie as varchar(3)) F2_SERIE, "
        cTRF2 += "        case substring(nf.cfop, 3, length(nf.cfop))          "
        cTRF2 += "           when '927' then cast(empresa.cpf as varchar(20))  "
        cTRF2 += "           else cast(pessoa.cpf as varchar(20))              "
        cTRF2 += "        end as F2_CGC,		                               "
        cTRF2 += "        case substring(nf.cfop, 3, length(nf.cfop))          "
        cTRF2 += "           when '927' then cast(empresa.nome as varchar(40)) "
        cTRF2 += "           else cast(pessoa.nome as varchar(40))             "
        cTRF2 += "        end AS F2_CLI,                                       "
		cTRF2 += "        nf.data_emissao  as F2_EMISSAO, cast(nf.modelo as varchar(5)) AS F2_ESPECIE,nf.valor_nota AS F2_VALBRUT, "
		//cTRF2 += "         case coalesce(nf.total_produto,0)  "
	    //cTRF2 += "            when 0 then nf.total_servico    "
	    //cTRF2 += "            else nf.total_produto           "
	    //cTRF2 += "         end as F2_VALMERC,                 "
		cTRF2 += "        nf.valor_nota AS F2_VALMERC,          "
		cTRF2 += "        nf.tipo as F2_TIPO, cast(replace(nf.cfop,'.','') as varchar (20)) as F2_CFO, cast(coalesce(nf.finalidade,'N') as varchar(1)) F2_TIPN,"
		cTRF2 += "        case when nf.modelo = '55' then (select cast(nfe.chave_acesso as varchar(50)) from nfe where nfe.nota_fiscal = nf.grid) "
		cTRF2 += "        when nf.modelo = '57' then (select cast(cte.chave_acesso as varchar(50)) from cte where cte.nota_fiscal = nf.grid) "
		cTRF2 += "        else '' "
		cTRF2 += "        end as F2_CHVNFE, "
		cTRF2 += "        cast(empresa.cpf as varchar(20)) EMISSOR , "//empresa.cpf AS EMISSOR, "//-- CNPJ Emissor
		cTRF2 += "		  nf.valor_ipi as F2_VALIPI, "//   --F2_VALIPI  - Valor total de IPI
		//cTRF2 += "    --F2_BASEIPI - Valor total BASE de IPI
		cTRF2 += "		  nf.valor_icms as F2_VALICM, "  // --F2_VALICM  - Valor total de ICM
		cTRF2 += "		  nf.base_icms as F2_BASEICM,   " //--F2_BASEICM - Valor total BASE ICM
		cTRF2 += "		  nf.valor_iss as F2_VALISS,   "// --F2_VALISS  - Valor total de ISS
		cTRF2 += "		  nf.base_iss as F2_BASEISS,   "//-- F2_BASEISS - Valor total BASE ISS
		cTRF2 += "		  nf.valor_retido_cofins as F2_VALIMP5,"//    --F2_VALIMP5 - Valor total de Cofins
		  //  -- F2_BASIMP5 - Valor total BASE Cofins
		cTRF2 += "		  nf.valor_retido_pis as F2_VALIMP6"//  -- F2_VALIMP6 - Valor total de PIS
		  // -- F2_BASIMP6 - Valor total BASE PIS
		cTRF2 += "   from nota_fiscal nf                   "
		cTRF2 += "        inner join empresa on (empresa.grid = nf.empresa) "
		cTRF2 += "        left  join pessoa  on (pessoa.grid  = nf.pessoa)  "
		cTRF2 += "		  left  join nota_fiscal_situacao nfs on (nf.grid = nfs.nota_fiscal)"
		cTRF2 += " where true and (nf.tipo = 'V' or nf.tipo='S' or nf.tipo = 'T') "
		//cTRF2 += "   and nf.data_emissao between '2016-11-01' and '2016-11-30'"
		cTRF2 += "   and nf.data_emissao between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"' "
		If !Empty(Alltrim(cFilIN))
			cTRF2+= " and empresa.cpf IN( "+cFilIN+" )"
		EndIf
		If !Empty(Alltrim(MV_PAR04))
			cTRF2+= " and nf.numero_nota >= '"+Alltrim(cValToChar(Val(MV_PAR03)))+"' "
			cTRF2+= " and nf.numero_nota <= '"+Alltrim(cValToChar(Val(MV_PAR04)))+"' "
		EndIf
		If !Empty(Alltrim(MV_PAR06))
			cTRF2+= " and nf.serie >= '"+Alltrim(MV_PAR05)+"'  "
			cTRF2+= " and nf.serie <= '"+Alltrim(MV_PAR06)+"'  "
		EndIf
		cTRF2 += "   and nf.numero_nota > -1 "
		cTRF2 += "   and nfs.situacao=310    "
		cTRF2 += "   and nf.modelo <> '65'   "
        //cTRF2 += "  and pessoa.cpf <> ''"
		cTRF2 += "   and nf.natureza_op <> '8589936492' "
		cTRF2 += "   and NOT EXISTS (SELECT 1           "
		cTRF2 += "                    FROM nota_fiscal_cupom "
		cTRF2 += "                   WHERE nota_fiscal = nf.grid) "
		cTRF2 += " order by nf.empresa,nf.cfop "

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRF2 ), "QRYTKE", .F., .T.)

		oXagCon:ConecPRT()
		DbSelectArea("QRYTKE")
		DbGoTop()
		While !EOF()

		 	cEmissor := ALLTRIM(QRYTKE->EMISSOR)
			cEmissor := STRTRAN(cEmissor,".","")
			cEmissor := STRTRAN(cEmissor,"-","")
			cEmissor := STRTRAN(cEmissor,"/","")

			oXagCon:ConecPRT()

			_cXFilial1 := cEmissor

		 	cEmpresa  := ""
			_cXFilial := ""

			DbSelectArea("SM0")
			DbGotop()
			dbseek(cEmpant)
			While !EOF()
				If 	SM0->M0_CGC == _cXFilial1
				 	cEmpresa  := SM0->M0_CGC
					_cXFilial := SM0->M0_CODFIL
					EXIT
				EndIf
				DbSelectArea("SM0")
				DbSkip()
			EndDo

			If _cXFilial <> ""
				If cEmpresa = cEmissor
                        _cCliente := ""

						_cCliente := Alltrim(QRYTKE->F2_CGC)
						_cCliente := STRTRAN(_cCliente,".","")
						_cCliente := STRTRAN(_cCliente,"-","")
						_cCliente := STRTRAN(_cCliente,"/","")

						if Alltrim(QRYTKE->F2_TIPN) == "D"

							DbSelectArea("SA2")
							DbSetOrder(3)
							If Dbseek(xFilial("SA2")+Alltrim(_cCliente))
							    cPessoa:= Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")
							    cA2PJ := ALLTRIM(cPessoa)
						    EndIf
						    SA2->(DbCloseArea())
						else
						 	DbSelectArea("SA1")
							DbSetOrder(3)
							If Dbseek(xFilial("SA1")+Alltrim(_cCliente))
							    cPessoa:= Transform(SA1->A1_CGC, "@R 99.999.999/9999-99")
							    cA2PJ := ALLTRIM(cPessoa)
							EndIf
							SA1->(DbCloseArea())

						endif

						//cA2PJ := ALLTRIM(cPessoa)
						cA2PJ := STRTRAN(cA2PJ,".","")
						cA2PJ := STRTRAN(cA2PJ,"-","")
						cA2PJ := STRTRAN(cA2PJ,"/","")

						if !Empty(Alltrim(cA2PJ))

							if Alltrim(QRYTKE->F2_TIPN) <> "D"
								DbSelectArea("SA1")
						        DbSetOrder(3)
						        If DbSeek(xFilial("SA1")+Alltrim(cA2PJ))
							        cCliente := SA1->A1_COD
							        cLoja    := SA1->A1_LOJA
                                    cNomeCli := SA1->A1_NOME
							    endif
							else
	 					    	DbSelectArea("SA2")
						        DbSetOrder(3)
						        If DbSeek(xFilial("SA2")+Alltrim(cA2PJ))
							        cCliente := SA2->A2_COD
							        cLoja    := SA2->A2_LOJA
                                    cNomeCli := SA2->A2_NOME
						        EndIf
						    EndIf
						endif

						cQuery := ""
						cQuery := "SELECT R_E_C_N_O_ FROM " + RETSQLNAME("SF2") + "  "
					    cQuery += "   WHERE F2_FILIAL  = '" + ALLTRIM(_cXFilial) +  "' "
						cQuery += "     AND F2_CLIENTE = '" + Alltrim(cCliente) +  "' "
						cQuery += "     AND F2_LOJA    = '" + Alltrim(cLoja)+"' "
						cQuery += "     AND F2_DOC     = '" + cValToChar(Strzero(QRYTKE->F2_DOC,9))  + "' "
						cQuery += "     AND F2_SERIE   = '" + Alltrim(QRYTKE->F2_SERIE) + "' "
						cQuery += "     AND D_E_L_E_T_ <> '*'  "

						If Select("QRY_SF2") <> 0
							dbSelectArea("QRY_SF2")
							dbCloseArea()
						Endif

						TCQuery cQuery NEW ALIAS "QRY_SF2"

						DbSelectArea("QRY_SF2")
						DbGoTop()
						While ! EOF()
							lExiste := .T.
							DbSelectArea("QRY_SF2")
							DbSkip()
						EndDo
						//If lExiste
							If _cXFilial <> ""
								nCont ++
								RecLock("SLA15",.T.)
								SLA15->FILIAL       := _cXFilial
								SLA15->DOCUMENTO    := cValToChar(Strzero(QRYTKE->F2_DOC,9))
								SLA15->NOMECLI      := Alltrim(QRYTKE->F2_CLI) //cNomeCli//POSICIONE('SA1',1,xFilial('SA1')+cCliente+cLoja,'A1_NOME')//QRYTKE->F2_DESC
								SLA15->SERIE        := Alltrim(QRYTKE->F2_SERIE)
								SLA15->CLIENTE  	:= cValToChar(QRYTKE->PESSOAGRID)//cCliente//cValToChar((QRYTKE->F2_CLIENTE))
								SLA15->EMISSAO      := QRYTKE->F2_EMISSAO
								SLA15->TIPO         := QRYTKE->F2_TIPO
								SLA15->CGC			:= QRYTKE->F2_CGC
								SLA15->TOTAL        := QRYTKE->F2_VALMERC
								SLA15->CDCLIENTE    := Alltrim(cCliente)
								SLA15->CLIENTELJ    := Alltrim(cLoja)
								SLA15->FINALID      := Alltrim(QRYTKE->F2_TIPN)
								SLA15->EXISTE   	:= IIF(lExiste,'E','N')
								SLA15->CNPJFIL   	:=  QRYTKE->EMISSOR
								MsUnlock()
							EndIf
						//EndIf
						lExiste:= .F.
					EndIf
				cA2PJ       := ""
	            cCliente := ""
	            cLoja       := ""
			EndIf
			DbSelectArea("QRYTKE")
			DbSkip()
		EndDo
	EndIf

	oXagCon:DescATS()

Return()

//----------------------------------------+
// 		Chama Função de importação        |
//----------------------------------------+
User Function AGR15IMP()

	If !msgyesno("Deseja continuar a importação?")
	   return()
	else
	   	Processa({|| Importa()}, "Importando Notas! Aguarde...")
	EndIF

Return()


//---------------------------------------+
//	  Função de importação dos dados	 |
//---------------------------------------+
Static Function Importa()

	Local lRotAut     := .T.
	Local aParam      := array(15)
	Private cProduto  := ""
	Private cCNPJ     := ""
	Private nItem     := 0
	Private cNumItem  := '01'
	Private _cXFilial := ""
	Private nParcela  := 0
	Private cCodCli   := ""
	Private cNotaFis  := ""
	Private cDtEmissao := ""
	Private cDtDigit   := ""
	Private cValIss    := 0
	Private cValIrr    := 0
	Private cValInss   := 0
	Private cValPis    := 0
	Private cValCof    := 0
	Private cValCsl    := 0
	Private cValDesconto := 0
	Private cStatus   := ""


	MsgInfo("Serão importadas "+cValtoChar(nCont)+" Nota(s)")

	If (!oXagCon:ConecATS())
		Conout("SLAAGR15 - *** Não foi possível conectar ao AutoSystem...")
	    RETURN
	Else
		//GERA QUERY DO CABEÇALHO
		U_15SLACAP()

		oXagCon:ConecPRT()

	  	FWrite(nHandle, "EMPRESA "+cEmpAnt+" | FILIAL "+cFilAnt+" "+ CRLF)
		DbSelectArea("TRF2")
		TRF2->(DbGoTop())
		ProcRegua(TRF2->(RecCount()))
		While TRF2->(!EOF())
			IncProc("Nota Fiscal : " + cValToChar(TRF2->F2_DOC) + " ..." )
			cEmissor := TRF2->EMISSOR
			cEmissor := ALLTRIM(TRF2->EMISSOR)
			cEmissor := STRTRAN(cEmissor,".","")
			cEmissor := STRTRAN(cEmissor,"-","")
			cEmissor := STRTRAN(cEmissor,"/","")
			
			oXagCon:ConecPRT()

			_cXFilial1 := cEmissor

		    cEmpresa  := ""
	        _cXFilial := ""

			DbSelectArea("SM0")
			DbGotop()
			Dbseek(cEmpAnt)
			While !EOF()
				If 	_cXFilial1 == SM0->M0_CGC
				   	cEmpresa:= SM0->M0_CGC
				   _cXFilial:= SM0->M0_CODFIL;EXIT
				EndIf
				DbSelectArea("SM0")
				DbSkip()
			EndDo

			If _cXFilial <> ""
	            cDtEmissao := ""
	            cDtDigit   := ""

				If cEmpresa = cEmissor
				  	cCGC:= TRF2->F2_CGC
			    	cCGC := ALLTRIM(TRF2->F2_CGC)
					cCGC := STRTRAN(cCGC,".","")
			   		cCGC := STRTRAN(cCGC,"-","")
			   		cCGC := STRTRAN(cCGC,"/","")
	                cDtEmissao := TRF2->F2_EMISSAO
	                cDtDigit   := TRF2->F2_DTDIGIT
		  			cNotaFis:= TRF2->F2_GRID
					nItem:= 1

					oXagCon:ConecATS()

					//CARREGA DADOS DO CLIENTE
		            U_15CLIA()

		            //GRAVA DADOS DO CLIENTE
                    if TRF2->F2_TIPN <> 'D'
                       U_15GRCLA() // --------------------- GRAVA CLIENTES
                    else
                       U_15GRCLeA() // -------------------- GRAVA FORNECEDORES
                    endif

		            oXagCon:ConecATS()

					//CARREGA INFORMAÇÕES DOS ITENS
					U_15SLAITE(TRF2->EMISSOR)

		 			If lCliente
							DbSelectArea("TRD2")
							TRD2->(DbGoTop())
							While TRD2->(!EOF())
								cProduto:= TRD2->D2_PRODUTO
								oXagCon:ConecATS()

								 //CARREGA INFORMAÇÕES DOS PRODUTOS
								U_15SLAPRO()

								DbSelectArea("TRB1")
								DbGoTop()
								While TRB1->(!EOF())
						        	If cValToChar(cProduto) == Alltrim(TRB1->B1_GRID)
										oXagCon:ConecPRT()

										//GRAVA PRODUTOS
										U_15GRVPro()

									 	If lProduto == .F.
									 		Exit
									 	EndIf
									EndIf
									DbSelectArea("TRB1")
									DbSkip()
								EndDo
						   		DbCloseArea("TRB1")
						   		If lProduto == .F.
									 Exit
								EndIf
						   		DbSelectArea("TRD2")
								TRD2->(DbSkip())
						   	EndDo

                            cParEspec:= "NF"
                            // BUSCA MODELO DA NF
                            cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
                            cQuery += " WHERE ZZ9_TABELA = '04' AND ZZ9_CAMP1 = '"+(Alltrim(TRF2->MODELO))+"' AND ZZ9_CAMP3 = 'S' "

                            If (Select ("QR04")<> 0)
                               QR04->(DbCloseArea())
                            EndIf
                            TcQuery cQuery New Alias "QR04"

                            DbSelectArea("QR04")
                            DbGoTop()
                            While !EOF()
                               cParEspec:= QR04->ZZ9_CAMP2
                               QR04->(DbSkip())
                            EndDo
                            DbCloseArea("QR04")

						   	DbSelectArea("TRD2")
							TRD2->(DbGoTop())
							While TRD2->(!EOF())
								If lProduto
									If TRF2->F2_DOC == TRD2->D2_DOC

										// GRAVA OS ITENS DA NF
										U_15GRVITE(cCGC)

										nItem ++
									EndIf
						   		Else
						   			Fwrite(nHandle, "ITENS DA NOTA FISCAL| ERRO  | NOTA FISCAL "+cValToChar(TRD2->D2_DOC)+"  ITEM "+cValToChar(cProduto)+"| NAO CADASTRADO NO MICROSIGA" + CRLF)
						   			lItemnf := .F.
						   			lItemnf1:= .F.
						   			Exit
						   		EndIf
								DbSelectArea("TRD2")
								TRD2->(DbSkip())
						   	EndDo

	                        cValIss  := 0
	                        cValIrr  := 0
	                        cValInss := 0
	                        cValPis  := 0
	                        cValCof  := 0
	                        cValCsl  := 0

						   	DbCloseArea("TRD2")
			                If lItemnf
			                   	oXagCon:ConecPRT()
			                	U_15GRCLAP(cCGC)
						    Else
						       	Fwrite(nHandle, "CAPA DA NOTA FISCAL | AVISO  | NOTA FISCAL "+cValToChar(TRF2->F2_DOC)+"|NAO IMPORTADA" + CRLF)
						    	lNFiscal:= .F.
						    	//lNFiscal1:= .F.
						    EndIf

							/*If lNFiscal
								if cStatus == "A"
								  oXagCon:ConecATS()
								  U_15SLADUP() // ------------------------- CARREGA INFORMAÇÕES DAS DUPLICATAS
								  DbSelectArea("TRE2")
								  DbGoTop()
								  While TRE2->(!EOF())
									  If (Alltrim(cValtoChar(TRF2->F2_DOC)) == Alltrim(TRE2->E2_NUM))
										 U_GRVDuplA(cCGC) // ------------------------- GRAVA A DUPLICATA
										 nParcela ++
									  EndIf
									  DbSelectArea("TRE2")
								      DbSkip()
								   EndDo
								endif
								nParcela := 0
							Else
								Fwrite(nHandle, "DUPLICATAS          | AVISO | DUPLICATA "+Alltrim(cValtoChar(TRF2->F2_DOC))+"             |NAO IMPORTADA" + CRLF)
								lDupli := .F.
								//lDupli1:= .F.
							EndIf
							DbCloseArea("TRE2")
							*/
						EndIf
					EndIf
			   	EndIf
			lCliente  := .T.
			lProduto  := .T.
			lItemnf   := .T.
			lNFiscal  := .T.
			lDupli    := .T.
			DbSelectArea("TRF2")
			DbSkip()
		EndDo
		TRF2->(DbCloseArea())
	EndIf


	If lCliente1 <> .T. .Or. lProduto1 <> .T. .Or. lItemnf1  <> .T. .Or. lNFiscal1 <> .T. .Or. lDupli1 <> .T.
		Fwrite(nHandle, "ERRO| CORRIGIR OS ERROS E IMPORTAR NOVAMENTE." + CRLF)
		FClose(nHandle)
		MsgAlert("***    Existem erros no arquivo favor verificar o log.txt     ***")
	Else
		MsgAlert("***    Importação Realizada com Sucesso!!!")
		Fwrite(nHandle, "SLAAGR15 - IMPORTACAO REALIZADA COM SUCESSO." + CRLF)
		FClose(nHandle)
	EndIf


	lCliente1 := .T.
	lProduto1 := .T.
	lItemnf1  := .T.
	lNFiscal1 := .T.
	lDupli1   := .T.
	closebrowse()

	oXagCon:DescATS()

Return ()

//------------------------------------------+
// BUSCA INFORMAÇÃO DA CAPA DA NOTA         |
//------------------------------------------+
User Function 15SLACAP()

	Local cTRF2 := ""

	cTRF2:= " select  nf.numero_nota    as F2_DOC,     cast(nf.serie as varchar(3)) F2_SERIE, "
	cTRF2+= "         nf.data_emissao   as F2_DTDIGIT, nf.data_saida as F2_EMISSAO, nf.valor_frete as F2_FRETE,  "
	cTRF2+= "         nf.valor_outr_des as F2_DESPESA, nf.base_icms  as F2_BASEICM, nf.valor_icms  as F2_VALICM, "
	//cTRF2+= "         nf.total_produto  as F2_VALMERC, "
	cTRF2+= "         nf.base_iss as F2_BASEISS, "
	cTRF2 += "		  nf.valor_retido_cofins as F2_VALIMP5,"//    --F2_VALIMP5 - Valor total de Cofins
    //  -- F2_BASIMP5 - Valor total BASE Cofins
	cTRF2 += "		  nf.valor_retido_pis as F2_VALIMP6,"//  -- F2_VALIMP6 - Valor total de PIS
	//cTRF2+= "         case coalesce(nf.total_produto,0)  "
	//cTRF2+= "            when 0 then nf.total_servico    "
	//cTRF2+= "            else nf.total_produto           "
	//cTRF2+= "         end as F2_VALMERC,                 "
    cTRF2+= "         nf.valor_nota     as F2_VALMERC, "
	cTRF2+= "         0                 as F2_DESCONT, " // removido campo nf.valor_desconto, desconto sempre zerado
	cTRF2+= "         nf.peso_liquido   as F2_PESOL,   nf.tipo_frete as F2_TPFRETE, "
	cTRF2+= "         nf.valor_seguro,                 nf.grid       as F2_GRID,    nf.tipo       as F2_TIPO,    "
	cTRF2+= "         nf.destinatario,                 nf.empresa,                  cast(nf.cpf   as varchar(20)) F2_CGC, "
	cTRF2+= "         cast(empresa.cpf as varchar(20)) as EMISSOR,   cast(nf.modelo as varchar(5)) as MODELO, cast(nf.nome AS varchar(50)) F2_DESC,         "
	cTRF2+= "         nf.base_subst                    as F2_BRICMS, nf.valor_subst as F2_ICMSRET, cast(replace(nf.cfop,'.','') as varchar (20)) as F2_CFO, "
	cTRF2+= "         case when nf.modelo = '55' then (select cast(nfe.chave_acesso as varchar(50)) from nfe where nfe.nota_fiscal = nf.grid) "
	cTRF2+= "              when nf.modelo = '57' then (select cast(cte.chave_acesso as varchar(50)) from cte where cte.nota_fiscal = nf.grid) "
	cTRF2+= "              else ''      "
	cTRF2+= "         end as F2_CHVNFE, "
	cTRF2+= "	      case              "
	cTRF2+= "            when nf.destinatario is null then (select np.codigo from pessoa np where np.grid = nf.pessoa) "
	cTRF2+= "            else (select nfp.pessoa from nota_fiscal_pessoa nfp where nfp.grid = nf.destinatario)         "
	cTRF2+= "         end as F2_CLIENTE,   "
	cTRF2+= "         nf.base_iss,             nf.valor_iss  F2_ISS,          nf.base_irrf F2_BASEIR,            nf.valor_irrf F2_VALIRF, "
	cTRF2+= "         nf.base_csll F2_BASCSLL, nf.valor_csll F2_VALCSLL,      nf.base_inss F2_BASEINS,           nf.valor_inss F2_INSS,   "
	cTRF2+= "         nf.valor_ipi F2_VALIPI,  nf.valor_retido_pis F2_VALPIS, nf.valor_retido_cofins F2_VALCOFI, cast(coalesce(nf.finalidade,'N') as varchar(1)) F2_TIPN, "
	cTRF2+= "         nf.valor_nota F2_VALBRUT  "
	cTRF2+= "    from nota_fiscal nf            "
	//cTRF2+= "       join nota_fiscal_pessoa nfp on (nfp.grid = nf.destinatario) "
	cTRF2+= "         join empresa on (empresa.grid = nf.empresa)   "
	//cTRF2+= "       join nfe nt  on (nt.nota_fiscal = nf.grid)    "
	cTRF2+= "         left join pessoa on (pessoa.grid = nf.pessoa) "
	cTRF2+= "         left join nota_fiscal_situacao nfs on (nf.grid = nfs.nota_fiscal) "
	cTRF2 += " where true and (nf.tipo = 'V' or nf.tipo='S' or nf.tipo='T') "
	cTRF2 += "   and nf.data_emissao between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"' "
	If !Empty(Alltrim(cFilIN))
       cTRF2+= " and empresa.cpf IN ("+cFilIN+") "
    EndIf
    If !Empty(Alltrim(MV_PAR04))
       cTRF2+= " and nf.numero_nota >= '"+Alltrim(cValToChar(Val(MV_PAR03)))+"' "
       cTRF2+= " and nf.numero_nota <= '"+Alltrim(cValToChar(Val(MV_PAR04)))+"' "
    EndIf
    If !Empty(Alltrim(MV_PAR06))
       cTRF2+= " and nf.serie >= '"+Alltrim(MV_PAR05)+"'  "
       cTRF2+= " and nf.serie <= '"+Alltrim(MV_PAR06)+"'  "
    EndIf
    cTRF2 += "   and nf.numero_nota > -1 "
    cTRF2 += "   and nfs.situacao=310    "
    cTRF2 += "   and nf.modelo <> '65'   "
    //cTRF2 += " and pessoa.cpf <> ''"
    cTRF2 += "   and nf.natureza_op <> '8589936492' "
    cTRF2 += "   and NOT EXISTS (SELECT 1           "
    cTRF2 += "                     FROM nota_fiscal_cupom      "
    cTRF2 += "                    WHERE nota_fiscal = nf.grid) "
    cTRF2 += "  order by nf.empresa,nf.cfop                    "

	If Select("TRF2") > 0
	   TRF2->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRF2 ), "TRF2", .F., .T.)

Return ()


//------------------------------------------+
// BUSCA INFORMAÇÃO DOS ITENS DA NOTA       |
//------------------------------------------+
User Function 15SLAITE(xEmissor)

	Local cTRD2:= ""

	cTRD2:= " select nfp.produto        as D2_PRODUTO, "
    //cTRD2+= "        nfp.preco_unit     as D2_VUNIT,   "
	cTRD2+= "        round((nfp.valor - nfp.valor_desconto) / nfp.quantidade,4)   as D2_VUNIT,  "
	//cTRD2+= "        nfp.valor          as D2_TOTAL,            "
	cTRD2+= "        nfp.valor - nfp.valor_desconto  as D2_TOTAL, "
	cTRD2+= "        nfp.quantidade     as D2_QUANT,              "
	//cTRD2+= "        nfp.perc_desconto  as D2_DESC,             "
	cTRD2+= "        0  as D2_DESC,  "
	cTRD2+= "        nfp.aliquota_icms  as D2_ALIQ   , nf.numero_nota     as D2_DOC,     "
	cTRD2+= "        nf.data_emissao    as D2_EMISSAO, cast(nf.serie  as varchar(3)) D2_SERIE, nfp.perc_red_base_icms   , nfp.valor_subst   as D2_ICMSRET, "
	cTRD2+= "        nfp.base_icms      as D2_BASEICM, nfp.valor_frete    as D2_VALFRE,  nfp.valor_seguro   as D2_SEGURO, "
	//cTRD2+= "        case                                                              "
	//cTRD2+= "          when nf.pessoa = 9906    then round(((nfp.valor/nf.total_produto) * nf.valor_desconto),5) "
	//cTRD2+= "          when nf.pessoa = 11981   then round(((nfp.valor/nf.total_produto) * nf.valor_desconto),5) "
	//cTRD2+= "          when nf.pessoa = 12715   then round(((nfp.valor/nf.total_produto) * nf.valor_desconto),5) "
	//cTRD2+= "          when nf.pessoa = 11068   then round(((nfp.valor/nf.total_produto) * nf.valor_desconto),5) "
	//cTRD2+= "          when nf.pessoa = 3278414 then round(((nfp.valor/nf.total_produto) * nf.valor_desconto),5) "
	//cTRD2+= "          else nfp.valor_desconto  "
	//cTRD2+= "        end as D2_VALDESC,       "
	//cTRD2+= "        nfp.valor_desconto as D2_VALDESC, "
	cTRD2+= "        0 as D2_VALDESC, "
	cTRD2+= "        nfp.valor_outr_des as D2_DESPESA, cast(nfp.cst as varchar(3)) as D2_CLASFIS, "
	//cTRD2+= "        round(((nfp.valor/case coalesce(nf.total_produto,0) when 0 then nf.total_servico else nf.total_produto end) * nf.valor_desconto),5) as D2_VALRAT,  "
	cTRD2+= "        0 as D2_VALRAT, "
	cTRD2+= "        nfp.valor_ipi      as D2_VALIPI , nfp.aliquota_ipi as D2_IPI,    nf.empresa as F2_EMPRESA, cast(replace(nfp.cfop,'.','') as varchar (20)) D2_CF, "
	cTRD2+= "        nfp.valor_icms     as D2_VALICMS, nfp.base_subst   as D2_BRICMS, cast(coalesce(nf.finalidade,'N') as varchar(1)) D2_TIPN,    "
	cTRD2+= "        cast(p.codigo      as varchar(20)) as PRODUTO, cast(p.nome as varchar (50)) DESCRICAO, nfp.numero_item  as D2_ITEM, "
	cTRD2+= "        case coalesce(nf.valor_retido_pis,0) when 0 then nfp.base_pis     else nfp.valor end as D2_BASEPIS, "
	cTRD2+= "        case coalesce(nf.valor_retido_pis,0) when 0 then nfp.aliquota_pis else 0         end as D2_ALQPIS,  nf.valor_retido_pis    as D2_VALPIS, "
	cTRD2+= "        case coalesce(nf.valor_retido_cofins,0) when 0 then nfp.base_cofins else nfp.valor end as D2_BASECOF, "
	cTRD2+= "        case coalesce(nf.valor_retido_cofins,0) when 0 then nfp.aliquota_cofins else 0     end as D2_ALQCOF,  nf.valor_retido_cofins as D2_VALCOF, "
	cTRD2+= "        case coalesce(nf.valor_csll,0) when 0 then nfp.base_csll     else nfp.valor end as D2_BASECSL, "
	cTRD2+= "        case coalesce(nf.valor_csll,0) when 0 then nfp.aliquota_csll else 0         end as D2_ALQCSL,  nf.valor_csll as D2_VALCSL, "
	cTRD2+= "        case coalesce(nf.valor_iss,0) when 0 then nfp.base_iss     else nfp.valor end as D2_BASEISS, "
	cTRD2+= "        case coalesce(nf.valor_iss,0) when 0 then nfp.aliquota_iss else 0         end as D2_ALIQISS, nf.valor_iss    as D2_VALISS, "
	cTRD2+= "        case coalesce(nf.valor_irrf,0) when 0 then nfp.base_irrf     else nfp.valor end as D2_BASEIRR, "
	cTRD2+= "        case coalesce(nf.valor_irrf,0) when 0 then nfp.aliquota_irrf else 0         end as D2_ALIQIRR, nf.valor_irrf as D2_VALIRR, "
	cTRD2+= "        case coalesce(nf.valor_inss,0) when 0 then nfp.base_inss     else nfp.valor end as D2_BASEINS, "
	cTRD2+= "        case coalesce(nf.valor_inss,0) when 0 then nfp.aliquota_inss else 0         end as D2_ALIQINS, nf.valor_inss as D2_VALINS  "
	cTRD2+= "   from nota_fiscal_produto nfp join nota_fiscal nf on (nf.grid = nfp.nota_fiscal) "
	cTRD2+= "        join produto p on(p.grid = nfp.produto) "
	cTRD2+= "        join empresa on (empresa.grid = nf.empresa) "
	cTRD2+= "  where nfp.nota_fiscal = '"+cValToChar(cNotaFis)+"' " //  and nf.tipo = 'C' "
	cTRD2+= "  and empresa.cpf = '"+alltrim(xEmissor)+"' "
	//cTRD2+= " and nf.data_emissao between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"' and nf.tipo = 'C'  "
	cTRD2+= "  order by nfp.numero_item "

	If Select("TRD2") > 0
	   TRD2->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRD2), "TRD2", .F., .T.)

Return()

//------------------------------------------+
//      BUSCA INFORMAÇÃO DO CLIENTE         |
//------------------------------------------+
User Function 15CLIA()

	Local cTRA1 := ""

	cTRA1:= "  select p.codigo         as A1_COD,                   cast(p.nome    as varchar(50)) A1_NOME  , cast(p.nome_reduzido as varchar(50)) A1_NREDUZ, "
	cTRA1+= "         cast(p.endereco  as varchar (50)) A1_END  ,   cast(p.bairro  as varchar(50)) A1_BAIRRO, cast(p.cidade        as varchar(50)) A1_MUN,    "
	cTRA1+= "         cast(p.estado    as varchar  (2)) A1_UF   ,   cast(p.cep     as varchar(11)) A1_CEP   , cast(p.tipo          as varchar(50)) A1_TIPO,   "
	cTRA1+= "         cast(p.cpf       as varchar (20)) A1_CGC  ,   cast(null      as varchar (3)) A1_DDD   , cast(p.fone          as varchar(20)) A1_TEL,    "
	cTRA1+= "         cast(p.contato   as varchar (45)) A1_CONTATO, cast(inscr_est as varchar(20)) A1_INSCR , cast(p.municipio     as varchar (7)) A1_COD_MUN "
	cTRA1+= "    from pessoa p "
	cTRA1+= "   where p.cpf = '"+Alltrim(TRF2->F2_CGC)+"' "

	If Select("TRA1") > 0
	   TRA1->(DbCloseArea())
	EndIF
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRA1), "TRA1", .F., .T.)

Return()

//------------------------------------------+
//        BUSCA INFORMAÇÃO DO PRODUTO       |
//------------------------------------------+
User Function 15SLAPRO()

	Local cTRB1    := ""

	cTRB1:=  " select cast(produto.codigo as varchar(255))  B1_PRODUTO, "
	cTRB1+=  " 		  cast(produto.nome as varchar(255))  B1_DESC, "
	cTRB1+=  "        produto.tipo       as B1_TIPO   , grupo_produto.codigo       as B1_GRUPO     , "
	cTRB1+=  "        cast(produto.unid_med as varchar(255))  B1_UM ,"
	cTRB1+=  "        cast(grupo_produto.nome as varchar(255)) B1_NOMEG , "
	cTRB1+=  "        cast(produto.codigo_ncm as varchar(255)) B1_POSIPI, "
	cTRB1+=  "        cast(produto.grid as varchar(255)) B1_GRID, "
	cTRB1+=  " 		  cast(produto.conta_estoque as varchar(20)) B1_CONTA "
	cTRB1+=  "   from produto "
	cTRB1+=  "        join grupo_produto on (grupo_produto.grid = produto.grupo) "
	cTRB1+=  " where produto.grid = '"+cValToChar(cProduto)+"'"

	If Select("TRB1") > 0
	   TRB1->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRB1), "TRB1", .F., .T.)

Return ()

//------------------------------------------+
//      BUSCA INFORMAÇÃO DA DUPLICATA       |
//------------------------------------------+
User Function 15SLADUP ()

	Local cTRE2 := ""

	cTRE2:= "  select cast(split_part(m.documento, '/', 1)as varchar(10)) E2_NUM , p.codigo, e.codigo, m.data  AS E2_EMISSAO, "
	cTRE2+= "         split_part(cast(m.documento as varchar(10)), '/', 2) E2_PARCELA, "
	cTRE2+= "         m.vencto AS E2_VENCTO, m.valor AS E2_VALOR,           "
	cTRE2+= "         cast(mm.nome  AS varchar(50)) E2_HIST, cast(p.cpf  as varchar (20)) E2_CNPJ, m.empresa "
	cTRE2+= "    from movto m "
	cTRE2+= "         join motivo_movto mm on (mm.grid = m.motivo and mm.tipo_movto = 1)"
	cTRE2+= "         join pessoa p  on (p.grid = m.pessoa)"
	cTRE2+= "         join empresa e on (e.grid = m.empresa)"
	cTRE2+= "   where split_part(cast(m.documento as varchar(10)), '/', 1) = '"+cValToChar(TRF2->F2_DOC)+"'" /* nota_fiscal.numero_nota */
	cTRE2+= "     and p.cpf = '"+ALLTRIM(TRF2->F2_CGC)+"' "
	cTRE2+= "     and m.empresa = '"+Alltrim(cValtoChar(TRF2->EMPRESA))+"' order by m.vencto"

	If Select("TRE2") > 0
	   TRE2->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRE2), "TRE2", .F., .T.)

Return()

//------------------------------------------+
//      GRAVA A INFORMAÇÃO DO PRODUTO       |
//------------------------------------------+
User Function 15GRVPro()

	Private cTipo   := ""
	Private cGrupo  := ""
	Private _cProd  := ""
	Private _cDescP := ""
	Private _cConta := SPACE(20)


	If Alltrim(TRB1->B1_GRID) == Alltrim(cValToChar(cProduto))
		// BUSCA OS CONTA DO PRODUTO
	    cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
	    cQuery += " WHERE ZZ9_TABELA = '03' AND ZZ9_CAMP1 = '"+Alltrim(TRB1->B1_CONTA)+"' "

		If (Select ("QR03")<> 0)
			QR03->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR03"

		DbSelectArea("QR03")
		DbGoTop()
		While !EOF()
			_cConta:= Alltrim(QR03->ZZ9_CAMP2)
	    	QR03->(DbSkip())
		EndDo
		DbCloseArea("QR03")


	    // BUSCA OS TIPOS DE PRODUTO
	    cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
	    cQuery += " WHERE ZZ9_TABELA = '02' AND ZZ9_CAMP1 = '"+(Alltrim(TRB1->B1_TIPO))+"' "

		If (Select ("QR02")<> 0)
			QR02->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR02"

		DbSelectArea("QR02")
		DbGoTop()
		While !EOF()
			cTipo:= Alltrim(QR02->ZZ9_CAMP2)
	    	QR02->(DbSkip())
		EndDo
		DbCloseArea("QR02")

	   	// BUSCA CÓDIGO DE PRODUTO ESPECIFICO
	    cGrupo:= StrZero(TRB1->B1_GRUPO,4)
	    cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
	    cQuery += " WHERE ZZ9_TABELA = 'B1' AND ZZ9_CAMP4 = '"+(Alltrim(TRB1->B1_PRODUTO))+"' "

		If (Select ("QRB1")<> 0)
			QRB1->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QRB1"

		DbSelectArea("QRB1")
		DbGoTop()
		While !EOF()
		    _cProd := Alltrim(QRB1->ZZ9_CAMP1)
		    _cDescP:= Alltrim(QRB1->ZZ9_CAMP2)
		    _cConta:= Alltrim(QRB1->ZZ9_CAMP3)
			QRB1->(DbSkip())
		EndDo

		DbCloseArea("QRB1")

		If _cProd == ""
			_cProd  := Alltrim(TRB1->B1_PRODUTO)
			_cDescP := Alltrim(TRB1->B1_DESC)
		EndIf

	    If lProduto
	       cQb1:= " SELECT B1_COD FROM " + RETSQLNAME("SB1") + " "
	       cQb1+= "  WHERE B1_COD  = '" + ALLTRIM(_cProd) + "'   "
	       cQb1+= "    AND B1_FILIAL = '" + xFilial("SB1") + "'  "
	       cQb1+= "    AND D_E_L_E_T_ <> '*'  "

	        If Select("QB1") > 0
	           QB1->(DbCloseArea())
	        EndIF

	        dbUseArea(.T., "TOPCONN", TCGenQry(,,cQb1), "QB1", .F., .T.)

		    DbSelectArea("SB1")
			DbSetOrder(1)
		    //IF !DbSeek(xFilial("SB1")+PADR(Alltrim(_cProd),((TamSx3('B1_COD')[1])))) //If !DbSeek(xFilial("SB1")+Alltrim(_cProd)) // Alterado Thiago SLA - 31/03/2015
		    IF EMPTY(QB1->B1_COD)
				DbSelectArea("SB1")
				Reclock("SB1",.T.)
			       	SB1->B1_COD    := _cProd
			       	SB1->B1_DESC   := _cDescP
			       	SB1->B1_TIPO   := cTipo
			       	SB1->B1_UM     := TRB1->B1_UM
			       	SB1->B1_LOCPAD := "01"
			       	SB1->B1_GRUPO  := StrZero(TRB1->B1_GRUPO,4)
			       	SB1->B1_MSBLQL := "2"
			       	SB1->B1_RASTRO := "N"
			        SB1->B1_LOCALIZ:= "N"
			        SB1->B1_POSIPI := TRB1->B1_POSIPI
			        SB1->B1_GARANT := "N"
			        SB1->B1_CONTA  := _cConta
			 	SB1->(MsUnlock())

				DbCloseArea("SB1")
	//			FWrite(nHandle, "CADASTRO PRODUTO |AVISO | COD PRODUTO: "+Alltrim(TRB1->B1_PRODUTO)+ " - "+ Alltrim(TRB1->B1_DESC) + "| GRAVADO "+ CRLF)
				FWrite(nHandle, "CADASTRO PRODUTO |AVISO | COD PRODUTO: "+Alltrim(_cProd)+ " - "+ Alltrim(TRB1->B1_DESC) + "| GRAVADO "+ CRLF)
			Else
	//			FWrite(nHandle, "CADASTRO PRODUTO |AVISO | COD PRODUTO: "+Alltrim(TRB1->B1_PRODUTO)+ " - "+ Alltrim(TRB1->B1_DESC)+ " | PRODUTO JA CADASTRADO" + CRLF)
				FWrite(nHandle, "CADASTRO PRODUTO |AVISO | COD PRODUTO: "+Alltrim(_cProd)+ " - "+ Alltrim(TRB1->B1_DESC)+ " | PRODUTO JA CADASTRADO" + CRLF)
		   		lProduto := .T. //.F.
				//lProduto1:= .T. //.F.
			EndIf
		Else
	//		FWrite(nHandle, "CADASTRO PRODUTO |ERRO  | COD PRODUTO: "+Alltrim(TRB1->B1_PRODUTO)+ " - "+ Alltrim(TRB1->B1_DESC)+ " | PRODUTO NAO CADASTRADO" + CRLF)
			FWrite(nHandle, "CADASTRO PRODUTO |ERRO  | COD PRODUTO: "+Alltrim(_cProd)+ " - "+ Alltrim(TRB1->B1_DESC)+ " | PRODUTO NAO CADASTRADO" + CRLF)
			lProduto := .F.
			//lProduto1:= .F.
		EndIf
	EndIf

	// lProduto:= .F.

	cQuery := " SELECT * FROM "+RETSQLNAME("SB1")+" "
	cQuery += " WHERE B1_COD = '"+(Alltrim(TRB1->B1_PRODUTO))+"' "

	If (Select ("QRBS")<> 0)
		QRBS->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QRBS"

	DbSelectArea("QRBS")
	DbGoTop()
	While QRBS->(!EOF())
	    lProduto:= .T.
		QRBS->(DbSkip())
	EndDo


Return(lProduto)

//------------------------------------------+
//      GRAVA INFORMAÇÃO DO CLIENTE         |
//------------------------------------------+
User Function 15GRCLA()

	Private cNum := ""
	Private cCEP := Alltrim(TRA1->A1_CEP)

	DbSelectArea("TRA1")
	TRA1->(DbGoTop())
	While TRA1->(!EOF())
		oXagCon:ConecPRT()
		If lCliente
			DbSelectArea("SA1")
			DbSetOrder(3)
			If !DbSeek(xFilial("SA1")+cCGC)
		    	cCEP := STRTRAN(cCEP,".","")
				cCEP := STRTRAN(cCEP,"-","")
				cCEP := STRTRAN(cCEP,"/","")
				DbSelectArea("SA1")
			 	Reclock("SA1",.T.)
			        SA1->A1_COD        := GETSXENUM('SA1','A1_COD') //NextNumero("SA1",1,"A1_COD",.T., )
			        ConfirmSX8()

                    SA1->A1_FILIAL     := xFilial('SA1')
			        SA1->A1_LOJA       := "01"
			        SA1->A1_NOME       := TRA1->A1_NOME
			        SA1->A1_NREDUZ     := IIf (Alltrim(TRA1->A1_NREDUZ) = "", TRA1->A1_NOME, TRA1->A1_NREDUZ)
			        SA1->A1_CEP        := cCEP
			        SA1->A1_END        := TRA1->A1_END
			        SA1->A1_BAIRRO     := TRA1->A1_BAIRRO
			        SA1->A1_EST        := TRA1->A1_UF
			        SA1->A1_MUN        := TRA1->A1_MUN
			        SA1->A1_TIPO       := TRA1->A1_TIPO
			        SA1->A1_INSCR      := TRA1->A1_INSCR
			        SA1->A1_CGC        := cCGC
			        SA1->A1_DDD        := TRA1->A1_DDD
			        SA1->A1_TEL        := TRA1->A1_TEL
			        SA1->A1_CONTATO    := TRA1->A1_CONTATO
                    SA1->A1_COD_MUN    := SubStr(TRA1->A1_COD_MUN,3,7)
			     SA1->(MsUnlock())

			EndIf
			FWrite(nHandle, "CADASTRO CLIENTE | AVISO | COD FORNEC "+cNum+ " | DESCRICAO "+ TRA1->A1_NOME + " | GRAVADO" +CRLF)
		Else
			Fwrite(nHandle, "CADASTRO CLIENTE | ERRO  | COD FORNEC "+cNum+ " | DESCRICAO "+ TRA1->A1_NOME + " | CLIENTE NAO CADASTRADO"+ CRLF)
			lCliente1 := .F.
			lCliente  := .F.
		EndIf
		DbCloseArea("SA1")
		DbSelectArea("TRA1")
		DbSkip()
	EndDo
	DbCloseArea("TRA1")

Return()


//------------------------------------------+
// GRAVA INFORMAÇÃO DO CLIENTE - DEVOLUCAO  |
//------------------------------------------+
User Function 15GRCLeA()
   Private cNum := ""
   Private cCEP := Alltrim(TRA1->A1_CEP)

   oXagCon:ConecPRT()

   DbSelectArea("TRA1")
   TRA1->(DbGoTop())
   While TRA1->(!EOF())

      oXagCon:ConecPRT()

      If lCliente
         DbSelectArea("SA2")
         DbSetOrder(3)
         If !DbSeek(xFilial("SA2")+cCGC)
            cCEP := STRTRAN(cCEP,".","")
            cCEP := STRTRAN(cCEP,"-","")
            cCEP := STRTRAN(cCEP,"/","")
            DbSelectArea("SA2")
            Reclock("SA2",.T.)
               SA2->A2_CLASSIF    := "00"
               SA2->A2_COD        := GETSXENUM('SA2','A2_COD') //NextNumero("SA2",1,"A2_COD",.T., )
               ConfirmSX8()

               SA2->A2_FILIAL     := xFilial('SA2')
               SA2->A2_LOJA       := "01"
               SA2->A2_NOME       := TRA1->A1_NOME
               SA2->A2_NREDUZ     := IIf (Alltrim(TRA1->A1_NREDUZ) = "", TRA1->A1_NOME, TRA1->A1_NREDUZ)
               SA2->A2_CEP        := cCEP
               SA2->A2_END        := TRA1->A1_END
               SA2->A2_BAIRRO     := TRA1->A1_BAIRRO
               SA2->A2_EST        := TRA1->A1_UF
               SA2->A2_MUN        := TRA1->A1_MUN
               SA2->A2_TIPO       := TRA1->A1_TIPO
               SA2->A2_INSCR      := TRA1->A1_INSCR
               SA2->A2_CGC        := cCGC
               SA2->A2_DDD        := TRA1->A1_DDD
               SA2->A2_TEL        := TRA1->A1_TEL
               SA2->A2_CONTATO    := TRA1->A1_CONTATO
               SA2->A2_COD_MUN    := SubStr(TRA1->A1_COD_MUN,3,7)
            SA2->(MsUnlock())
         EndIf
         Fwrite(nHandle, "CADASTRO DE FORNECEDOR | AVISO  | FORNECEDOR " +cCGC+ " | DESCRICAO "+ TRA1->A1_NOME + " | NOTA DEVOL. GRAVADO. " + CRLF)
      Else
         FWrite(nHandle, "CADASTRO DE FORNECEDOR | ERRO | FORNECEDOR "+cCGC+" | DESCRICAO "+ TRA1->A1_NOME + " | FORNECEDOR NOTA DEVOL. NAO CADASTRADO." + CRLF)
         lCliente  := .F.
         lCliente1 := .F.
      EndIf

      DbSelectArea("TRA1")
      TRA1->(DbSkip())
   EndDo
   DbCloseArea("TRA1")

Return()


//------------------------------------------+
// GRAVA INFORMAÇÃO DA CAPA DA NOTA         |
//------------------------------------------+
User Function 15GRCLAP(cCNPJ)

	Local   cQry3   := ""
	Private cCodCli := ""
	Private cLojaCli:= ""
	Private cEstFor := ""
	Private lSF3    := .F.
	Private cTipoNota := ""

	cCNPJ := ALLTRIM(TRF2->F2_CGC)
	cCNPJ := STRTRAN(cCnpj,".","")
	cCNPJ := STRTRAN(cCnpj,"-","")
	cCNPJ := STRTRAN(cCnpj,"/","")

	oXagCon:ConecPRT()

	if TRF2->F2_TIPN <> "D"
	   DbSelectArea("SA1")
	   DbSetOrder(3)
	   If DbSeek(xFilial("SA1")+cCNPJ)
	     cCodCli := SA1->A1_COD
	     cLojaCli:= SA1->A1_LOJA
	     cEstFor := SA1->A1_EST
	   EndIf
	else
	   DbSelectArea("SA2")
	   DbSetOrder(3)
	   If DbSeek(xFilial("SA2")+cCNPJ)
		 cCodCli := SA2->A2_COD
		 cLojaCli:= SA2->A2_LOJA
		 cEstFor := SA2->A2_EST
	   EndIf
	endif

	cDocumento:= cValtoChar(StrZero(TRF2->F2_DOC,9))
    //cParEspec:= "NF"

	// BUSCA MODELO DA NF
	/* funcao foi transferida para antes de inserir os itens da nota, devido a validacao da variavel cParEspec
	cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
	cQuery += " WHERE ZZ9_TABELA = '04' AND ZZ9_CAMP1 = '"+(Alltrim(TRF2->MODELO))+"' AND ZZ9_CAMP3 = 'S' "

	If (Select ("QR04")<> 0)
		QR04->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QR04"

	DbSelectArea("QR04")
	DbGoTop()
	While !EOF()
	   	cParEspec:= QR04->ZZ9_CAMP2
		QR04->(DbSkip())
	EndDo
	DbCloseArea("QR04")
	*/
	//cTipoNota :=  Alltrim(TRF2->F2_TIPN)
	//if Alltrim(TRF2->F2_TIPN) <> "D"
	//  cTipoNota := "N"
	//endif

	DbSelectArea("SF2")
	DbSetOrder(1)
	If !DbSeek(_cXFilial+Alltrim(cDocumento)+Alltrim(cValTochar(TRF2->F2_SERIE))+Alltrim(cCodCli)+Alltrim(cLojaCli)+TRF2->F2_TIPN)
	    DbSelectArea("SF2")
	    Reclock("SF2",.T.)

	       	SF2->F2_FILIAL  := _cXFilial
	       	SF2->F2_DOC     := Alltrim(cDocumento)
	       	SF2->F2_SERIE   := Alltrim(cValTochar(TRF2->F2_SERIE))
	       	SF2->F2_EMISSAO := TRF2->F2_EMISSAO
	       	SF2->F2_TIPO    := TRF2->F2_TIPN
	       	SF2->F2_CLIENTE := cCodCli
	       	SF2->F2_LOJA    := cLojaCli
	       	SF2->F2_EST     := cEstFor
	       	SF2->F2_ESPECIE := cParEspec
	        SF2->F2_COND    := "001"
	        SF2->F2_FRETE   := TRF2->F2_FRETE
	       	SF2->F2_CHVNFE  := TRF2->F2_CHVNFE
	       	SF2->F2_FORMUL  := "N"

			SF2->F2_BRICMS  := TRF2->F2_BRICMS
			SF2->F2_ICMSRET := TRF2->F2_ICMSRET
	        SF2->F2_BASCSLL := TRF2->F2_BASCSLL
	        SF2->F2_VALCSLL := TRF2->F2_VALCSLL
	        SF2->F2_BASEINS := TRF2->F2_BASEINS
	        SF2->F2_VALIPI  := TRF2->F2_VALIPI
	        SF2->F2_VALPIS  := TRF2->F2_VALPIS
	        SF2->F2_VALCOFI := TRF2->F2_VALCOFI
	        SF2->F2_VALBRUT := TRF2->F2_VALBRUT
	       	SF2->F2_VALICM  := TRF2->F2_VALICM
	       	SF2->F2_VALMERC := TRF2->F2_VALMERC
	      	SF2->F2_DESCONT := TRF2->F2_DESCONT
	        SF2->F2_DESPESA := TRF2->F2_DESPESA
	       	SF2->F2_BASEICM := TRF2->F2_BASEICM
	       	SF2->F2_BASEISS := TRF2->F2_BASEISS

	       	SF2->F2_VALIMP5 := TRF2->F2_VALIMP5//Valor total de Cofins
			SF2->F2_VALIMP6 := TRF2->F2_VALIMP6//Valor total BASE PIS
	    	SF2->F2_VALISS  := TRF2->F2_ISS
	    	SF2->F2_VALINSS := TRF2->F2_INSS

	       	//Calcular para gravar
	       	//SF2->F2_BASEIPI := TRF2->F2_BASEIPI
	       	//SF2->F2_BASIMP5 := TRF2->F2_BASIMP5//- Valor total BASE Cofins
		    //SF2->F2_BASIMP6 := TRF2->F2_BASIMP6//- Valor total BASE PIS

		    //VERIFICAR  - Campos que haviam na Importação de ENTRADA
	       	//SF2->F2_DUPL    := Alltrim(cDocumento)
	       	//SF2->F2_DTLANC  := TRF2->F2_EMISSAO
	       	//SF2->F2_DTDIGIT := TRF2->F2_DTDIGIT //TRF2->F2_EMISSAO
	       	//SF2->F2_RECBMTO := TRF2->F2_DTDIGIT //TRF2->F2_EMISSAO
	        //SF2->F2_ORIIMP  := "SLAARG15"
	        //SF2->F2_INSS    := TRF2->F2_INSS
	        //SF2->F2_ISS     := TRF2->F2_ISS
	        //SF2->F2_BASEIR  := TRF2->F2_BASEIR
	        //SF2->F2_VALIRF  := TRF2->F2_VALIRF
	       	//SF2->F2_PESOL   := TRF2->F2_PESOL
	       	//SF2->F2_STATUS  := cStatus //"A"

	        cValIss  := TRF2->F2_ISS
	        //cValIrr  := TRF2->F2_VALIRF
	        cValInss := TRF2->F2_INSS

	        cValPis  := TRF2->F2_VALPIS
	        cValCof  := TRF2->F2_VALCOFI
		    cValCsl  := TRF2->F2_VALCSLL

	    SF2->(MsUnlock())
	    DbCloseArea("SF2")
	    FWrite(nHandle, "CAPA DA NOTA        | AVISO | NUM NOTA   "+Alltrim(cDocumento)+ " FORNEC "+ cCodCli  + " | GRAVADA COM SUCESSO" + CRLF)
	EndIf

	Return()

//------------------------------------------+
// GRAVA INFORMAÇÃO DOS ITENS DA NOTA       |
//------------------------------------------+
User Function 15GRVITE(cCNPJ)

	Local cQuery    := ""
	Private cCodCli := ""
	Private cLojaCli:= ""
	Private cEstCli := ""
	Private cPj     := ""
	Private cTES    := ""
	Private cCfop   := ""
	Private cConta  := ""
	Private lSD2    := .F.
	Private _cProd  := ""
	Private cLocal  := ""
	Private cCtaRec := ""
	Private cNumSeq := Space(TamSx3('D2_NUMSEQ')[1])

	_cProd := Alltrim(TRD2->PRODUTO)
	cDocd1 := cValtoChar(StrZero(TRD2->D2_DOC,9))

	cPj := ALLTRIM(cCNPJ)
	cPj := STRTRAN(cPj,".","")
	cPj := STRTRAN(cPj,"-","")
	cPj := STRTRAN(cPj,"/","")

	oXagCon:ConecPRT()

   	if TRD2->D2_TIPN == "D"
	   DbSelectArea("SA2")
	   DbSetOrder(3)
	   If DbSeek(xFilial("SA2")+cPj)
	      cCodCli := SA2->A2_COD
	      cLojaCli:= SA2->A2_LOJA
	   EndIf
	else
	   DbSelectArea("SA1")
	   DbSetOrder(3)
	   If DbSeek(xFilial("SA1")+cPj)
	      cCodCli := SA1->A1_COD
	      cLojaCli:= SA1->A1_LOJA
          cEstCli := SA1->A1_EST
	   EndIf
	endif


	cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
	cQuery += " WHERE ZZ9_TABELA = 'B1' AND ZZ9_CAMP4 = '"+(Alltrim(TRD2->PRODUTO))+"' "

	If (Select ("QRB1")<> 0)
		QRB1->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QRB1"

	DbSelectArea("QRB1")
	DbGoTop()
	While !EOF()
	    _cProd := Alltrim(QRB1->ZZ9_CAMP1)
		QRB1->(DbSkip())
	EndDo

	DbCloseArea("QRB1")

	cQry := " SELECT *"
	cQry += " FROM "+RetSQLName("SD2")
	cQry += " WHERE "+RetSQLName("SD2")+".D_E_L_E_T_ <> '*'"
	cQry += " AND D2_FILIAL = '"+_cXFilial+"' AND D2_DOC = '"+Alltrim(cDocd1)+"'"
	cQry += " AND D2_SERIE = '"+Alltrim(cValToChar(TRD2->D2_SERIE))+"' AND D2_CLIENTE = '"+Alltrim(cCodCli)+"' "
	cQry += " AND D2_LOJA = '"+Alltrim(cLojaCli)+"' "
	cQry += " AND D2_COD = '"+Alltrim(_cProd)+"' "
	cQry += " AND (D2_ITEM = '"+cValToChar(TRD2->D2_ITEM)+"' OR D2_ITEM = '"+cValToChar(StrZero(TRD2->D2_ITEM,2))+"') "

	If (Select ("QRY")<> 0)
		QRY->(DbCloseArea())
	EndIf
	TcQuery cQry New Alias "QRY"

	DbSelectArea("QRY")
	DbGoTop()
	While !EOF()
		lSD2:= .T.
		QRY->(DbSkip())
	EndDo

	cUM      := ""
	cCConta  := ""
	cTP      := ""
	cGrupoD1 := ""
	cLocal   := ""
    cCtaRec  :=	""

	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+PADR(Alltrim(_cProd),((TamSx3('B1_COD')[1])))) //DbSeek(xFilial("SB1")+Alltrim(_cProd))
	     cUM      := SB1->B1_UM
	     cCConta  := SB1->B1_CONTA
	     cTP      := SB1->B1_TIPO
	     cGrupoD1 := SB1->B1_GRUPO
	     cLocal   := SB1->B1_LOCPAD
         cCtaRec  := SB1->B1_CTAREC
	EndIf

	cCfop:= SubStr(TRD2->D2_CF,2,4)
	cTES    := '498'
	cStatus := 'A'

	// BUSCA CFOP
	cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
	cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP7 = 'S' "

	If (Select ("QR05")<> 0)
		QR05->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QR05"

	DbSelectArea("QR05")
	DbGoTop()
	While !EOF()
		cTES:= Alltrim(QR05->ZZ9_CAMP1)

		if Alltrim(QR05->ZZ9_CAMP6) == "S"
	      cStatus := ''
		endif

	   	QR05->(DbSkip())
	EndDo
	DbCloseArea("QR05")

	//----------------------------------//
	cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
	cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD2->D2_CLASFIS)+"' AND ZZ9_CAMP7 = 'S' "

	If (Select ("QR05")<> 0)
		QR05->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QR05"

	DbSelectArea("QR05")
	DbGoTop()
	While !EOF()
		cTES:= Alltrim(QR05->ZZ9_CAMP1)

		if Alltrim(QR05->ZZ9_CAMP6) == "S"
	      cStatus := ''
		endif

	   	QR05->(DbSkip())
	EndDo
	DbCloseArea("QR05")

	//----------------------------------//
	If TRD2->D2_VALICMS == 0
	//----------------------------------//
		cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' "
		cQuery += " AND ZZ9_CAMP3  = 'D2_VALICMS==0' AND ZZ9_CAMP7 = 'S' "

		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		DbGoTop()
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

	        if Alltrim(QR05->ZZ9_CAMP6) == "S"
	          cStatus := ''
	        endif

		   	QR05->(DbSkip())
		EndDo
		DbCloseArea("QR05")

		//----------------------------------//
		cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD2->D2_CLASFIS)+"' "
		cQuery += " AND ZZ9_CAMP3  = 'D2_VALICMS==0' AND ZZ9_CAMP7 = 'S' "
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		DbGoTop()
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

	        if Alltrim(QR05->ZZ9_CAMP6) == "S"
	          cStatus := ''
	        endif

		   	QR05->(DbSkip())
		EndDo
		DbCloseArea("QR05")

	Else

		//----------------------------------//
		cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"'  "
		cQuery += " AND ZZ9_CAMP4  = 'D2_VALICMS>0' AND ZZ9_CAMP7 = 'S' "
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		DbGoTop()
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

	        if Alltrim(QR05->ZZ9_CAMP6) == "S"
	          cStatus := ''
	        endif

		   	QR05->(DbSkip())
		EndDo
		DbCloseArea("QR05")

		//----------------------------------//
		cQuery := " SELECT * FROM "+RETSQLNAME("ZZ9")+" "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD2->D2_CLASFIS)+"' "
		cQuery += " AND ZZ9_CAMP4  = 'D2_VALICMS>0' AND ZZ9_CAMP7 = 'S' "
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		DbGoTop()
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

	        if Alltrim(QR05->ZZ9_CAMP6) == "S"
	          cStatus := ''
	        endif

		   	QR05->(DbSkip())
		EndDo
		DbCloseArea("QR05")
	EndIf    
	    
	//CHAMADO[76035] - CC Despesa na Saida
   	cCtaDebLP := ""
   	cCc 	  := ""
	//Posifiona SF4
	DbSelectarea('SF4')
	DbSetorder(1)
	Dbseek(xfilial('SF4')+cTES ) 
	cCtaDebLP := U_AGR118() //Chama a Função que preenche a Conta no LP
	If substr(ALLTRIM(cCtaDebLP),1,2) >= '52'
		cCc  := GetCCPadra(_cXFilial)
	Endif
     
	
	If !lSD2
	  cValDesconto := 0

	  cValDesconto := TRD2->D2_VALDESC
	  if Alltrim(cParEspec) <> "SPED"
	    cValDesconto := TRD2->D2_VALRAT
	  endif

		    DbSelectArea("SD2")
	//    	cNumSeq := ProxNum() // Alterado devido erros com a função ProxNum()
			cNumSeq := GETMV("MV_DOCSEQ")
			cNumSeq := SOMA1(cNumSeq)
			IF GETMV("MV_DOCSEQ") < cNumSeq
				PUTMV("MV_DOCSEQ", cNumSeq)
			ENDIF

            If TRD2->D2_ITEM > 99
               If Alltrim(cNumItem) == ""
                  cNumItem := "99"
               EndIf
               cNumItem := Soma1(cNumItem)
            Else
               cNumItem := cValToChar(StrZero(TRD2->D2_ITEM,2))
            EndIf

		    Reclock("SD2",.T.)
		    	SD2->D2_FILIAL  := _cXFilial
		    	SD2->D2_ITEM    := cNumItem //cValToChar(TRD2->D2_ITEM) /* cValToChar(nItem)
		   		SD2->D2_COD		:= Alltrim(_cProd)
		   		SD2->D2_UM      := cUM
				SD2->D2_LOCAL   := cLocal
				SD2->D2_CONTA   := cCConta
				SD2->D2_TES     := cTES
				SD2->D2_TP      := cTP
			   //	SD2->D2_DESCRI  := TRD2->DESCRICAO
				SD2->D2_QUANT   := TRD2->D2_QUANT
				SD2->D2_PRCVEN  := TRD2->D2_VUNIT
				SD2->D2_PRUNIT  := TRD2->D2_VUNIT
				SD2->D2_TOTAL   := TRD2->D2_TOTAL
				SD2->D2_VALBRUT := TRD2->D2_TOTAL
				//SD2->D2_CUSTO1   := TRD2->D2_TOTAL
				SD2->D2_DESCON	:= cValDesconto //TRD2->D2_VALDESC
				SD2->D2_CLIENTE := cCodCli
				SD2->D2_LOJA    := cLojaCli
				SD2->D2_EST     := cEstCli
				SD2->D2_GRUPO   := cGrupoD1
				SD2->D2_ITEMCC := "01"
				SD2->D2_DOC     := Alltrim(cDocd1)
				SD2->D2_EMISSAO := cDtEmissao//TRF2->F2_EMISSAO //TRD2->D2_EMISSAO
				SD2->D2_DTDIGIT := cDtDigit  //TRF2->F2_DTDIGIT //TRD2->D2_EMISSAO
				SD2->D2_SERIE   := Alltrim(cValToChar(TRD2->D2_SERIE))
				SD2->D2_BASEICM := TRD2->D2_BASEICM
				SD2->D2_NUMSEQ  := cNumSeq //SD2->D2_NUMSEQ  := ProxNum() // GETMV("MV_DOCSEQ")
			    SD2->D2_TIPO    := TRD2->D2_TIPN //"N"
			    //SD2->D2_ORIIMP  := "SLAARG15"
			    SD2->D2_CF      := TRD2->D2_CF
			    SD2->D2_PICM    := TRD2->D2_ALIQ
			    SD2->D2_VALICM  := TRD2->D2_VALICMS

				SD2->D2_DESC    := TRD2->D2_DESC
			    SD2->D2_BRICMS  := TRD2->D2_BRICMS
			    SD2->D2_ICMSRET := TRD2->D2_ICMSRET
			    SD2->D2_SEGURO  := TRD2->D2_SEGURO
			    SD2->D2_VALFRE  := TRD2->D2_VALFRE
			    SD2->D2_DESPESA := TRD2->D2_DESPESA
			    SD2->D2_BASEIRR := TRD2->D2_BASEIRR
			    SD2->D2_ALQIRRF := TRD2->D2_ALIQIRR
			    SD2->D2_VALIRRF  := TRD2->D2_VALIRR
			    SD2->D2_BASEISS := TRD2->D2_BASEISS
			    SD2->D2_ALIQISS := TRD2->D2_ALIQISS
			    SD2->D2_VALISS  := TRD2->D2_VALISS
			    SD2->D2_BASEINS := TRD2->D2_BASEINS
			    SD2->D2_ALIQINS := TRD2->D2_ALIQINS
			    SD2->D2_VALINS  := TRD2->D2_VALINS
			    SD2->D2_VALIPI  := TRD2->D2_VALIPI
			    SD2->D2_IPI     := TRD2->D2_IPI
			    SD2->D2_CLASFIS := TRD2->D2_CLASFIS
	            SD2->D2_BASEPIS := TRD2->D2_BASEPIS
	            SD2->D2_ALQPIS  := TRD2->D2_ALQPIS
	            SD2->D2_VALPIS  := TRD2->D2_VALPIS
	            SD2->D2_BASECOF := TRD2->D2_BASECOF
	            SD2->D2_ALQCOF  := TRD2->D2_ALQCOF
	            SD2->D2_VALCOF  := TRD2->D2_VALCOF
	            SD2->D2_BASECSL := TRD2->D2_BASECSL
	            SD2->D2_ALQCSL  := TRD2->D2_ALQCSL
	            SD2->D2_VALCSL  := TRD2->D2_VALCSL
	            SD2->D2_RATEIO  := "2"
                SD2->D2_CTAREC  := cCtaRec  
                SD2->D2_CCUSTO  := cCc
	            /*
	            cValIss := cValIss + TRD2->D2_VALISS
	            cValIrr := cValIrr + TRD2->D2_VALIRR
	            cValPis := cValPis + TRD2->D2_VALPIS
	            cValCof := cValCof + TRD2->D2_VALCOF
	            cValCsl := cValCsl + TRD2->D2_VALCSL
	            */
			SD2->(MsUnlock())
			DbCloseArea("SD2")
			FWrite(nHandle, "ITENS DA NOTA       | AVISO | ITEM  "+cValToChar(TRD2->D2_ITEM)+ " | PRODUTO "+ TRD2->PRODUTO +" | NF: "+ Alltrim(cDocd1) + " | GRAVADO" + CRLF)
	Else
		FWrite(nHandle,     "ITENS DA NOTA       | AIVSO | ITEM  "+cValToChar(TRD2->D2_ITEM)+ " | PRODUTO "+ TRD2->PRODUTO +" | NF: "+ Alltrim(cDocd1) + " | ITEM DA NF JA INSERIDO "+ CRLF)
		lItemnf:= .F.

	EndIf
	QRY->(DbCloseArea())

Return()


User Function AGR15LEG()

	BrwLegenda(cCadastro,"Legenda",    {{"BR_VERDE"      ,"Apto a Importar"    },;
										{"BR_LARANJA"    ,"Erro Cliente Não cadastrado" },;
										{"BR_AZUL"  	 ,"Nota Fiscal ou Chave já existe" }})

Return(.T.) 

//CHAMADO[76035] - CC Despesa na Saida
//Função retorna o Centro de Custo padrão da filial do Posto
Static Function GetCCPadra(xFilCC)
 	
 	Local cQuery  := "" 
 	Local cRet    := ""   
 	Local aAreaCC := getarea()                      
      
	// Busca CC padrão da Filial
	cQuery := " SELECT ZZ9_CAMP2 FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
	cQuery += " WHERE ZZ9_TABELA = 'CC' AND ZZ9_CAMP1 = '"+(Alltrim(xFilCC))+"' AND D_E_L_E_T_ = '' "

	If (Select ("QRCC")<> 0)
		QRCC->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QRCC"

	DbSelectArea("QRCC")
	DbGoTop()
	While !EOF()
		cRet := Alltrim(QRCC->ZZ9_CAMP2)
		QRCC->(DbSkip())
	EndDo

	DbCloseArea("QRCC") 
	
	RestArea(aAreaCC)  
	
Return cRet



//------------------------------------------+
// GRAVA INFORMAÇÃO DAS DUPLICATAS          |
//------------------------------------------+
/*User Function GRVDuplA(cCGC)

Local  cQuery       := ""
Private cPrefixo	:= _cXFilial+SubStr((TRF2->F2_SERIE),1,1) // ribas filial + serie
Private lSE2        := .F.
Private cCodCli     := ""
Private cCodE2      := ""

cCPF := ALLTRIM(cCGC)
cCPF := STRTRAN(cCPF,".","")
cCPF := STRTRAN(cCPF,"-","")
cCPF := STRTRAN(cCPF,"/","")

oXagCon:ConecPRT()
if TRF2->F2_TIPN <> "D"
   DbSelectArea("SA2")
   DbSetOrder(3)
   If DbSeek(xFilial("SA2")+cCPF)
     cCodCli := SA2->A1_COD
     cLojaCli:= SA2->A1_LOJA
     cNOMECLI:= SA2->A1_NOME
   EndIf
else
   DbSelectArea("SA1")
   DbSetOrder(3)
   If DbSeek(xFilial("SA1")+cCPF)
     cCodCli := SA1->A1_COD
     cLojaCli:= SA1->A1_LOJA
     cNOMECLI:= SA1->A1_NOME
   EndIf
endif


cDocE2:= cValtoChar(StrZero(TRF2->F2_DOC,9))

cQuery := " SELECT *"
cQuery += " FROM "+RetSQLName("SE2")
cQuery += " WHERE "+RetSQLName("SE2")+".D_E_L_E_T_ <> '*'"
cQuery += " AND E2_FILIAL = '' AND E2_PREFIXO = '"+Alltrim(cValToChar(cPrefixo))+"' "
cQuery += " AND E2_NUM = '"+Alltrim(cDocE2)+"' AND  E2_FORNECE = '"+Alltrim(cCodCli)+"' AND E2_LOJA = '"+Alltrim(cLojaCli)+"'"
cQuery += " AND E2_PARCELA = '"+Alltrim(cValToChar(nParcela))+"' "

If (Select ("QRY1")<> 0)
	QRY1->(DbCloseArea())
EndIf
TcQuery cQuery New Alias "QRY1"

DbSelectArea("QRY1")
DbGoTop()
While !EOF()
	lSE2:= .T.
	QRY1->(DbSkip())
EndDo


If !lSE2
	DbSelectArea("SE2")
	/*RecLock("SE2",.T.)
	    SE2->E2_PREFIXO		:= Alltrim(cValToChar(cPrefixo))
		SE2->E2_NUM			:= Alltrim(cDocE2)
		SE2->E2_PARCELA  	:= cValToChar(nParcela)
		SE2->E2_FORNECE		:= cCodCli
		SE2->E2_LOJA		:= cLojaCli
		SE2->E2_NOMFOR		:= cNOMECLI
		SE2->E2_EMISSAO  	:= cDtEmissao //TRF2->F2_EMISSAO //TRE2->E2_EMISSAO
		SE2->E2_VENCTO 		:= TRE2->E2_VENCTO
		SE2->E2_VENCREA		:= TRE2->E2_VENCTO
		SE2->E2_VALOR		:= TRE2->E2_VALOR //- (cValIss + cValIrr + cValPis + cValCof + cValCsl + cValInss)
		SE2->E2_EMIS1 		:= cDtDigit //TRF2->F2_DTDIGIT //TRE2->E2_EMISSAO
		SE2->E2_HIST		:= TRE2->E2_HIST
		SE2->E2_LA			:= ""
		SE2->E2_SALDO		:= TRE2->E2_VALOR //- (cValIss + cValIrr + cValPis + cValCof + cValCsl + cValInss) //TRE2->E2_VALOR
		SE2->E2_VALLIQ		:= TRE2->E2_VALOR //- (cValIss + cValIrr + cValPis + cValCof + cValCsl + cValInss) //TRE2->E2_VALOR
		SE2->E2_VENCORI		:= TRE2->E2_VENCTO //TRE2->E2_EMISSAO
		SE2->E2_MOEDA		:= 1
		SE2->E2_VLCRUZ		:= TRE2->E2_VALOR //- (cValIss + cValIrr + cValPis + cValCof + cValCsl + cValInss) //TRE2->E2_VALOR
		SE2->E2_ORIGEM		:= "MATA100"
		SE2->E2_TIPO 		:= "NF"
		SE2->E2_ORIIMP  	:= "SLAAGR15"
		SE2->E2_FILORIG		:= _cXFilial
		SE2->E2_MSFIL       := _cXFilial
		SE2->E2_MSEMP       := cEmpAnt

        If (Alltrim(cEmpAnt) == "21")
          SE2->E2_FILIAL := _cXFilial
        EndIf

		SE2->E2_INSS    := cValInss
		SE2->E2_IRRF    := cValIrr
		SE2->E2_VRETIRF := cValIrr
		SE2->E2_ISS     := cValIss
		SE2->E2_VRETCSL := cValCsl
		SE2->E2_CSLL    := cValCsl
		SE2->E2_PIS     := cValPis
		SE2->E2_COFINS  := cValCof
		SE2->E2_BASEPIS := TRE2->E2_VALOR
		SE2->E2_BASECOF := TRE2->E2_VALOR
		SE2->E2_BASECSL := TRE2->E2_VALOR
		SE2->E2_BASEINS := TRE2->E2_VALOR

	SE2->(MsUnLock()) *//*
	DbCloseArea("SE2")
	FWrite(nHandle, "DUPLICATAS          | AVISO | NUM DUPLICATA "+Alltrim(cDocE2)+ " | FORNEC "+ cCodCli  + " | GRAVADO COM SUCESSO" + CRLF)
Else
	FWrite(nHandle, "DUPLICATAS          | ERRO  | NUM DUPLICATA "+Alltrim(cDocE2)+ " | FORNEC "+ cCodCli  + " | NAO IMPORTADA, JA EXISTENTE NO MICROSIGA" + CRLF)
	lSE2:= .F.
EndIf

  cValIss := 0
  cValIrr := 0
  cValPis := 0
  cValCof := 0
  cValCsl := 0

 QRY1->(DbCloseArea())

Return()  */
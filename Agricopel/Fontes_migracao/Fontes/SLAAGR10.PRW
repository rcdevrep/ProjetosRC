#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------+
// Data : 17/02/2016  Autor: Layze Ribas |
//---------------------------------------+
// Descrição: Integração de Notas de     |
// Entrada Protheus x AutoSystem Manual  |
//---------------------------------------+

User Function SLAAGR10()
	 
	Private	cCadastro := "Importação de Entradas"
	Private cFilAte   := ""
	Private cPessoa   := ""
	Private cFilDe    := ""
	Private cParEspec := ""
	Private cEmpresa  := ""
	Private cLojaFor  := ""
	Private cCodFor   := ""
	Private cNomeFor  := ""
	Private cEstFor   := ""
	Private _cNome    := StrTran(DTOC(Date()),"/","_")+"-"+StrTran(time(),":","")
	Private nHandle   := FCREATE("log_autosystem\SLAAGR10_"+_cNome+".txt")
	Private nCont     := 0
	Private oXagCon   := XAGConexao():New()

	Private lFornece  := .T.
	Private lProduto  := .T.
	Private lItemnf   := .T.
	Private lNFiscal  := .T.
	Private lDupli    := .T.
	Private lFornece1 := .T.
	Private lProduto1 := .T.
	Private lItemnf1  := .T.
	Private lNFiscal1 := .T.
	Private lDupli1   := .T.

	Private aRotina   := { { "Importar" ,"U_AGX720A()" , 0, 1},;
	{ "Legenda"  ," "           , 0, 3}}

	If cEmpAnt <> '20' .AND. cEmpAnt <> '13'.AND. cEmpAnt <> '17' .AND. cEmpAnt <> '21'.AND. cEmpAnt <> '24'.AND. cEmpAnt <> '25'.AND. cEmpAnt <> '27' .AND. cEmpAnt <> '44' .AND.cEmpAnt <> '51'.AND. cEmpAnt <> '52'.AND. cEmpAnt <> '53'.AND. cEmpAnt <> '57'
		Alert("Atenção! Esta rotina está disponivel somente para as Empresas 13, 17, 20, 21, 24, 25, 27, 44, 51, 52, 53, 57!")
		Return()
	EndIf

	cPerg := "SLAAGR10"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Data de          ?","mv_ch1","D",08,0,0,"G","","mv_par01" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Data até         ?","mv_ch2","D",08,0,0,"G","","mv_par02" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Num. NF          ?","mv_ch3","C",09,0,0,"G","","mv_par03" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Série NF         ?","mv_ch4","C",03,0,0,"G","","mv_par04" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Filial           ?","mv_ch5","C",02,0,0,"G","","mv_par05" ,"","","","","","","","","","","","","","","SM0"})
	AADD(aRegistros,{cPerg,"06","Fornecedor       ?","mv_ch6","C",09,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SA2"})

	U_CriaPer(cPerg,aRegistros)

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	aCampos  := {}
	aTam     := {}
	cArqTrab := ""

	aTam:=TamSX3("F1_FILIAL")
	AADD(aCampos,{"FILIAL"         ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("A2_NOME")
	AADD(aCampos,{"NOMEFOR"        ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_DOC")
	AADD(aCampos,{"DOCUMENTO"      ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_SERIE")
	AADD(aCampos,{"SERIE"          ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_FORNECE")
	AADD(aCampos,{"FORNECEDOR"     ,"C", 15,0 } )

	aTam:=TamSX3("F1_EMISSAO")
	AADD(aCampos,{"EMISSAO"        ,"D",8      ,      0 } )

	aTam:=TamSX3("F1_TIPO")
	AADD(aCampos,{"TIPO"           ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_CGC")
	AADD(aCampos,{"CGC"            ,"C",20     ,0       } )

	aTam:=TamSX3("F1_VALMERC")
	AADD(aCampos,{"TOTAL"          ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_FORNECE")
	AADD(aCampos,{"CDFORNEC"     ,"C", 15,0 } )

	aTam:=TamSX3("F1_LOJA")
	AADD(aCampos,{"FORNECLJ"     ,"C", 15,0 } )

	aTam:=TamSX3("F1_TIPO")
	AADD(aCampos,{"FINALID", "C",aTam[1],aTam[2], "" } )

	cArqTrab:= CriaTrab(aCampos,.T.)

	If Select("SLA01") <> 0
		dbSelectArea("SLA01")
		dbCloseArea()
	Endif

	dbUseArea(.T.,,cArqTrab,"SLA01",.T.,.F.)
	Indregua("SLA01",cArqTrab,"DOCUMENTO",,,OemToAnsi("Selecionando Registros..."))

	Processa({|| U_BUSCASLA()}, "Buscando Info. no Autosystem,Aguarde...")

	//U_CriaSLA()
	aCampBrw:= {}

	aTam:=TamSX3("F1_FILIAL")
	AADD(aCampBrw,{"Filial", "FILIAL", "C",2,0, "" } )

	aTam:=TamSX3("F1_EMISSAO")
	AADD(aCampBrw,{"Emissão", "EMISSAO", "D",8,0, "" } )

	aTam:=TamSX3("F1_DOC")
	AADD(aCampBrw,{"Nota Fiscal", "DOCUMENTO","C",aTam[1],aTam[2], "" } )

	aTam:=TamSX3("F1_SERIE")
	AADD(aCampBrw,{"Serie", "SERIE","C",aTam[1],aTam[2], "" } )

	aTam:=TamSX3("F1_FORNECE")
	AADD(aCampBrw,{"Fornecedor (Grid)", "FORNECEDOR","C",15,0, "" } )

	aTam:=TamSX3("F1_TIPO")
	AADD(aCampBrw,{"Tipo", "TIPO","C",aTam[1],aTam[2], "" } )

	aTam:=TamSX3("A2_NOME")
	AADD(aCampBrw,{"Nome Fornecedor", "NOMEFOR","C",aTam[1],aTam[2], "" } )

	aTam:=TamSX3("F1_CGC")
	AADD(aCampBrw,{"CNPJ/CPF", "CGC","C",15,0, "" } )

	aTam:=TamSX3("F1_VALMERC")
	AADD(aCampBrw,{"Total", "TOTAL","C",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("F1_FORNECE")
	AADD(aCampBrw,{"Fornecedor (Microsiga)", "CDFORNEC","C",15,0, "" } )

	aTam:=TamSX3("F1_LOJA")
	AADD(aCampBrw,{"Loja (Microsiga)", "FORNECLJ","C",15,0, "" } )

	aTam:=TamSX3("F1_TIPO")
	AADD(aCampBrw,{"Finalidade", "FINALID","C",aTam[1],aTam[2], "" } )

	dbSelectArea("SLA01")
	dbSetOrder(1)
	mBrowse(6,1,22,75,"SLA01",aCampBrw)

Return()

//--------------------------------------------+
//                                            |
//--------------------------------------------+
User Function BUSCASLA()

	Local cQuery      := ""
	Local lRet        := .T.
	Private _cXFilial := ""
	Private lExiste   := .T.
	Private cA2PJ     := ""
	Private cLoja     := ""
	Private cFornecedor:= ""
	Private lValCGC   := .F.

	If nHandle = -1
		Conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	Else
		FWrite(nHandle, Time() + CRLF)
	Endif

	If (!oXagCon:ConecATS())
		MsgAlert("Não foi possivel conectar ao Autosytem ...")
		FWrite(nHandle, "SLAARG10 - Não foi possivel conectar ao Autosystem." + CRLF)
		Return
	Else
		FWrite(nHandle, "SLAAGR10 - Conexão com o servidor estabelecida." + CRLF)

		oXagCon:ConecPRT()

		DbSelectArea("SM0")
		DbGotop()
		While !Eof()
			If SM0->M0_CODIGO == cEmpAnt
				If Alltrim(MV_PAR05) == SM0->M0_CODFIL
					cFilAte:= Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")
				EndIf
			EndIf
			DbSelectArea("SM0")
			DbSkip()
		EndDo
		DbSelectArea("SM0")
		DbGotop()
		While !Eof()
			If SM0->M0_CODIGO == cEmpAnt
				If cFilAnt == SM0->M0_CODFIL
					cFilDe:= Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")
				EndIf
			EndIf
			DbSelectArea("SM0")
			DbSkip()
		EndDo

		If !Empty(ALLTRIM(cPessoa))
			DbSelectArea("SA2")
			DbSetOrder(1)
			If Dbseek(xFilial("SA2")+Alltrim(MV_PAR06)+"01")
				cPessoa:= Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")
				cA2PJ := ALLTRIM(cPessoa)
			EndIf
			SA2->(DbCloseArea())
		EndIf

		oXagCon:ConecATS()

		cTRF1:= " select  nf.numero_nota    as F1_DOC    , cast(nf.serie as varchar(3)) F1_SERIE, cast(nf.mlid as varchar(20)) as F1_MLID, "
		cTRF1+= "         nf.data_emissao   as F1_DTDIGIT, nf.data_saida as F1_EMISSAO, nf.valor_frete   as F1_FRETE, "
		cTRF1+= "         nf.valor_outr_des as F1_DESPESA, nf.base_icms  as F1_BASEICM, nf.valor_icms    as F1_VALICM,"
		//cTRF1+= "         nf.total_produto  as F1_VALMERC,       "
		cTRF1+= "         case coalesce(nf.total_produto,0)  "
		cTRF1+= "            when 0 then nf.total_servico    "
		cTRF1+= "            else nf.total_produto           "
		cTRF1+= "         end as F1_VALMERC,                 "
		cTRF1+= "         nf.valor_desconto as F1_DESCONT, nf.peso_liquido as F1_PESOL,"
		cTRF1+= "         nf.tipo_frete     as F1_TPFRETE, nf.valor_seguro,                 nf.grid         as F1_GRID , nf.tipo as F1_TIPO, "
		cTRF1+= "         nf.destinatario                , nf.empresa                     , cast(nf.cpf as varchar(20)) F1_CGC, "
		cTRF1+= "         cast(empresa.cpf as varchar(20)) DESTINO, cast(nf.modelo as varchar(5)) MODELO, cast(nf.nome AS varchar(50)) F1_DESC,   "
		cTRF1+= "         nf.base_subst     as F1_BRICMS , nf.valor_subst as F1_ICMSRET, cast(replace(nf.cfop,'.','') as varchar (20)) as F1_CFO, "
		cTRF1+= "         case when nf.modelo = '55' then (select cast(nfe.chave_acesso as varchar(50)) from nfe where nfe.nota_fiscal = nf.grid) "
		cTRF1+= "              when nf.modelo = '57' then (select cast(cte.chave_acesso as varchar(50)) from cte where cte.nota_fiscal = nf.grid) "
		cTRF1+= "              else '' "
		cTRF1+= "         end as F1_CHVNFE, "
		cTRF1+= "	      case    "
		cTRF1+= "            when nf.destinatario is null then (select np.codigo from pessoa np where np.grid = nf.pessoa) "
		cTRF1+= "            else (select nfp.pessoa from nota_fiscal_pessoa nfp where nfp.grid = nf.destinatario)      "
		cTRF1+= "         end as F1_FORNECE,  "
		cTRF1+= "         nf.base_iss,             nf.valor_iss  F1_ISS,          nf.base_irrf F1_BASEIR,            nf.valor_irrf F1_VALIRF, "
		cTRF1+= "         nf.base_csll F1_BASCSLL, nf.valor_csll F1_VALCSLL,      nf.base_inss F1_BASEINS,           nf.valor_inss F1_INSS,   "
		cTRF1+= "         nf.valor_ipi F1_VALIPI,  nf.valor_retido_pis F1_VALPIS, nf.valor_retido_cofins F1_VALCOFI, cast(coalesce(nf.finalidade,'N') as varchar(1)) F1_TIPN, "
		cTRF1+= "         nf.valor_nota F1_VALBRUT  "
		cTRF1+= "    from nota_fiscal nf "
		//cTRF1+= "       join nota_fiscal_pessoa nfp on (nfp.grid = nf.destinatario) "
		cTRF1+= "         join empresa on (empresa.grid = nf.empresa) "
		//cTRF1+= "       join nfe nt on (nt.nota_fiscal = nf.grid) "
		cTRF1+= "   where nf.data_emissao between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"'  and nf.tipo in ('C','D','E') "
		cTRF1+= "     and nf.numero_nota > -1                                                                                 "
		cTRF1+= "     and nf.situacao <> 'C'                                                                                  "
		//cTRF1+= "     and nf.hora_saida < (now() - interval '24 hour')                                                        "
		//cTRF1+= "   and nf.numero_nota in (422757,422756) "
		If !Empty(Alltrim(MV_PAR03))
			cTRF1+= " and nf.numero_nota = '"+Alltrim(cValToChar(Val(MV_PAR03)))+"' "
		EndIf
		If !Empty(Alltrim(MV_PAR04))
			cTRF1+= " and nf.serie = '"+Alltrim(MV_PAR04)+"'  "
		EndIf
		If !Empty(Alltrim(cFilAte))
			cTRF1+= " and empresa.cpf = '"+cFilAte+"' "
		Else
			cTRF1+= " and empresa.cpf = '"+cFilDe+"' "
		EndIf
		If !Empty(Alltrim(MV_PAR06))
			CTRF1+= " and nf.cpf = '"+cPessoa+"' "
		EndIf
		cTRF1+= " order by nf.data_emissao"

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRF1 ), "QRYTKE", .F., .T.)

		oXagCon:ConecPRT()
		DbSelectArea("QRYTKE")
		DbGoTop()
		While !EOF()

			cDest := ALLTRIM(QRYTKE->DESTINO)
			cDest := STRTRAN(cDest,".","")
			cDest := STRTRAN(cDest,"-","")
			cDest := STRTRAN(cDest,"/","")

			oXagCon:ConecPRT()
			If !Empty(Alltrim(cFilAte))
				_cXFilial1 := Alltrim(cFilAte)
			Else
				_cXFilial1 := Alltrim(cFilDe)
			EndIf

			_cXFilial1 := STRTRAN(_cXFilial1,".","")
			_cXFilial1 := STRTRAN(_cXFilial1,"-","")
			_cXFilial1 := STRTRAN(_cXFilial1,"/","")

			cEmpresa  := ""
			_cXFilial := ""

			DbSelectArea("SM0")
			DbGotop()
			While !EOF()
				If 	_cXFilial1 == SM0->M0_CGC
					cEmpresa  := SM0->M0_CGC
					_cXFilial := SM0->M0_CODFIL
				EndIf
				DbSelectArea("SM0")
				DbSkip()
			EndDo

			If _cXFilial <> ""
				If cEmpresa = cDest

					_cFornece:= Alltrim(QRYTKE->F1_CGC)
					_cFornece := STRTRAN(_cFornece,".","")
					_cFornece := STRTRAN(_cFornece,"-","")
					_cFornece := STRTRAN(_cFornece,"/","")

					if Alltrim(QRYTKE->F1_TIPN) == "D"
						If !Empty(ALLTRIM(MV_PAR06))
							DbSelectArea("SA1")
							DbSetOrder(1)
							If Dbseek(xFilial("SA1")+Alltrim(MV_PAR06)+"01")
								cPessoa:= Transform(SA1->A1_CGC, "@R 99.999.999/9999-99")
								cA2PJ := ALLTRIM(cPessoa)
							EndIf
							SA1->(DbCloseArea())
						EndIf

						If Empty(Alltrim(cA2PJ))
							DbSelectArea("SA1")
							DbSetOrder(3)
							If Dbseek(xFilial("SA1")+Alltrim(_cFornece))
								cPessoa:= Transform(SA1->A1_CGC, "@R 99.999.999/9999-99")
								cA2PJ := ALLTRIM(cPessoa)
							EndIf
							SA1->(DbCloseArea())
						endif
					else
						If !Empty(ALLTRIM(MV_PAR06))
							DbSelectArea("SA2")
							DbSetOrder(1)
							If Dbseek(xFilial("SA2")+Alltrim(MV_PAR06)+"01")
								cPessoa:= Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")
								cA2PJ := ALLTRIM(cPessoa)
							EndIf
							SA2->(DbCloseArea())
						EndIf

						If Empty(Alltrim(cA2PJ))
							DbSelectArea("SA2")
							DbSetOrder(3)
							If Dbseek(xFilial("SA2")+Alltrim(_cFornece))
								cPessoa:= Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")
								cA2PJ := ALLTRIM(cPessoa)
							EndIf
							SA2->(DbCloseArea())
						EndIf
					endif

					//cA2PJ := ALLTRIM(cPessoa)
					cA2PJ := STRTRAN(cA2PJ,".","")
					cA2PJ := STRTRAN(cA2PJ,"-","")
					cA2PJ := STRTRAN(cA2PJ,"/","")

					if !Empty(Alltrim(cA2PJ))
						if Alltrim(QRYTKE->F1_TIPN) <> "D"
							DbSelectArea("SA2")
							DbSetOrder(3)
							If DbSeek(xFilial("SA2")+Alltrim(cA2PJ))
								cFornecedor := SA2->A2_COD
								cLoja       := SA2->A2_LOJA
							EndIf
						else
							DbSelectArea("SA1")
							DbSetOrder(3)
							If DbSeek(xFilial("SA1")+Alltrim(cA2PJ))
								cFornecedor := SA1->A1_COD
								cLoja       := SA1->A1_LOJA
							endif
						EndIf
					endif

					cQuery := ""
					cQuery := "SELECT R_E_C_N_O_ FROM " + RETSQLNAME("SF1") + " (NOLOCK) "
					cQuery += "   WHERE F1_FILIAL  = '" + ALLTRIM(_cXFilial) +  "' "
					cQuery += "     AND F1_FORNECE = '" + Alltrim(cFornecedor) +  "' "
					cQuery += "     AND F1_LOJA    = '" + Alltrim(cLoja)+"' "
					cQuery += "     AND F1_DOC     = '" + cValToChar(Strzero(QRYTKE->F1_DOC,9))  + "' "
					cQuery += "     AND F1_SERIE   = '" + Alltrim(QRYTKE->F1_SERIE) + "' "
					cQuery += "     AND D_E_L_E_T_ = ''  "

					If Select("QRY_SF2") <> 0
						dbSelectArea("QRY_SF2")
						dbCloseArea()
					Endif

					TCQuery cQuery NEW ALIAS "QRY_SF2"

					DbSelectArea("QRY_SF2")
					DbGoTop()
					While ! EOF()
						lExiste := .F.
						DbSelectArea("QRY_SF2")
						DbSkip()
					EndDo
					If lExiste
						If _cXFilial <> ""
							nCont ++
							RecLock("SLA01",.T.)
							SLA01->FILIAL       := _cXFilial
							SLA01->DOCUMENTO    := cValToChar(Strzero(QRYTKE->F1_DOC,9))
							SLA01->NOMEFOR      := QRYTKE->F1_DESC
							SLA01->SERIE        := Alltrim(QRYTKE->F1_SERIE)
							SLA01->FORNECEDOR   := cValToChar((QRYTKE->F1_FORNECE))
							SLA01->EMISSAO      := QRYTKE->F1_EMISSAO
							SLA01->TIPO         := QRYTKE->F1_TIPO
							SLA01->CGC			:= QRYTKE->F1_CGC
							SLA01->TOTAL        := QRYTKE->F1_VALMERC
							SLA01->CDFORNEC     := Alltrim(cFornecedor)
							SLA01->FORNECLJ     := Alltrim(cLoja)
							SLA01->FINALID      := Alltrim(QRYTKE->F1_TIPN)
							MsUnlock()
						EndIf
					EndIf
					lExiste:= .T.
				EndIf
				cA2PJ       := ""
				cFornecedor := ""
				cLoja       := ""
			EndIf
			DbSelectArea("QRYTKE")
			DbSkip()
		EndDo
	EndIf

	oXagCon:DescATS()

Return()

//--------------------------------------------+
//                                            |
//--------------------------------------------+
User Function AGX720A()

	If !msgyesno("Deseja continuar a importação?")
		return()
	else
		Processa({|| Importa()}, "Importando Notas! Aguarde...")
	EndIF

Return()

Static Function Importa()

	Local lRotAut     := .T.
	Local aParam      := array(15)
	Private cProduto  := ""
	Private cCNPJ     := ""
	Private nItem     := 0
	Private _cXFilial := ""
	Private nParcela  := 0
	Private cCodFor   := ""
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
	Private nQtdeReg  := 0

	MsgInfo("Serão importadas "+cValtoChar(nCont)+" Nota(s)")

	If (!oXagCon:ConecATS())
		Conout("SLAAGR10 - *** Não foi possível conectar ao AutoSystem...")
		RETURN
	Else
		U_SLACapaA()

		oXagCon:ConecPRT()

		FWrite(nHandle, "EMPRESA "+cEmpAnt+" | FILIAL "+cFilAnt+" "+ CRLF)
		DbSelectArea("TRF1")
		TRF1->(DbGoTop())
		ProcRegua(TRF1->(RecCount()))
		While TRF1->(!EOF())
			IncProc("Nota Fiscal : " + cValToChar(TRF1->F1_DOC) + " ..." )
			cDest := TRF1->DESTINO
			cDest := ALLTRIM(TRF1->DESTINO)
			cDest := STRTRAN(cDest,".","")
			cDest := STRTRAN(cDest,"-","")
			cDest := STRTRAN(cDest,"/","")

			oXagCon:ConecPRT()

			If !Empty(Alltrim(cFilAte))
				_cXFilial1 := Alltrim(cFilAte)
			Else
				_cXFilial1 := Alltrim(cFilDe)
			EndIf

			_cXFilial1 := STRTRAN(_cXFilial1,".","")
			_cXFilial1 := STRTRAN(_cXFilial1,"-","")
			_cXFilial1 := STRTRAN(_cXFilial1,"/","")

			cEmpresa  := ""
			_cXFilial := ""

			DbSelectArea("SM0")
			DbGotop()
			While !EOF()
				If 	_cXFilial1 == SM0->M0_CGC
					cEmpresa:= SM0->M0_CGC
					_cXFilial:= SM0->M0_CODFIL
				EndIf
				DbSelectArea("SM0")
				DbSkip()
			EndDo

			If _cXFilial <> ""
				cDtEmissao := ""
				cDtDigit   := ""

				If cEmpresa = cDest
					cCGC:= TRF1->F1_CGC
					cCGC := ALLTRIM(TRF1->F1_CGC)
					cCGC := STRTRAN(cCGC,".","")
					cCGC := STRTRAN(cCGC,"-","")
					cCGC := STRTRAN(cCGC,"/","")
					cDtEmissao := TRF1->F1_EMISSAO
					cDtDigit   := TRF1->F1_DTDIGIT
					cNotaFis:= TRF1->F1_GRID
					nItem:= 1

					oXagCon:ConecATS()
					U_SLAFornA() // --------------------- CARREGA INFORMAÇÃO DOS FORNECEDORES

					if TRF1->F1_TIPN <> 'D'
						U_GRVFornA() // --------------------- GRAVA FORNECEDORES
					else
						U_GRVClieA() // --------------------- GRAVA CLIENTES
					endif

					oXagCon:ConecATS()
					U_SLAItemA() // --------------------- CARREGA INFORMAÇÕES DOS ITENS
					If lFornece
						DbSelectArea("TRD1")
						TRD1->(DbGoTop())
						While TRD1->(!EOF())
							cProduto:= TRD1->D1_PRODUTO
							oXagCon:ConecATS()
							U_SLAProdA()   // --------------------- CARREGA INFORMAÇÕES DOS PRODUTOS
							DbSelectArea("TRB1")
							DbGoTop()
							While TRB1->(!EOF())
								If cValToChar(cProduto) == Alltrim(TRB1->B1_GRID)
									oXagCon:ConecPRT()
									U_GRVProdA() // -------------------------- GRAVA PRODUTOS
									//DbSelectArea("SB1")
									//DbSetOrder(1)
									//If !DbSeek(xFilial("SB1'")+Alltrim(TRB1->B1_PRODUTO))
									//	lProduto := .F.
									//	Exit
									//Else
									//	lProduto := .T.
									//EndIf
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
							DbSelectArea("TRD1")
							TRD1->(DbSkip())
						EndDo

						DbSelectArea("TRD1")
						TRD1->(DbGoTop())
						While TRD1->(!EOF())
							If lProduto
								If TRF1->F1_DOC == TRD1->D1_DOC
									U_GRVItemA(cCGC) // ------------------------------- GRAVA OS ITENS DA NF
									nItem ++
								EndIf
							Else
								Fwrite(nHandle, "ITENS DA NOTA FISCAL| ERRO  | NOTA FISCAL "+cValToChar(TRD1->D1_DOC)+"  ITEM "+cValToChar(cProduto)+"| NAO CADASTRADO NO MICROSIGA" + CRLF)
								lItemnf := .F.
								lItemnf1:= .F.
								Exit
							EndIf
							DbSelectArea("TRD1")
							TRD1->(DbSkip())
						EndDo

						cValIss  := 0
						cValIrr  := 0
						cValInss := 0
						cValPis  := 0
						cValCof  := 0
						cValCsl  := 0

						DbCloseArea("TRD1")
						If lItemnf
							oXagCon:ConecPRT()
							U_GRVCapaA(cCGC)
						Else
							Fwrite(nHandle, "CAPA DA NOTA FISCAL | AVISO  | NOTA FISCAL "+cValToChar(TRF1->F1_DOC)+"|NAO IMPORTADA" + CRLF)
							lNFiscal:= .F.
							//lNFiscal1:= .F.
						EndIf
						

						If lNFiscal
							if cStatus == "A"
								oXagCon:ConecATS()
								U_SLADuplA() // ------------------------- CARREGA INFORMAÇÕES DAS DUPLICATAS
								DbSelectArea("TRE2")
								DbGoTop()
								//Count To nQtdeReg
								nQtdeReg := Contar("TRE2","!Eof()") //RecCount("TRE2")
								DbGoTop()
								While TRE2->(!EOF())
									If (Alltrim(cValtoChar(TRF1->F1_DOC)) == Alltrim(TRE2->E2_NUM))
										U_GRVDuplA(cCGC) // ------------------------- GRAVA A DUPLICATA
										nParcela ++
									EndIf
									DbSelectArea("TRE2")
									DbSkip()
								EndDo
							endif
							nParcela := 0
							nQtdeReg := 0
						Else
							Fwrite(nHandle, "DUPLICATAS          | AVISO | DUPLICATA "+Alltrim(cValtoChar(TRF1->F1_DOC))+"             |NAO IMPORTADA" + CRLF)
							lDupli := .F.
							//lDupli1:= .F.
						EndIf
						DbCloseArea("TRE2")
					EndIf
				EndIf
			EndIf
			lFornece  := .T.
			lProduto  := .T.
			lItemnf   := .T.
			lNFiscal  := .T.
			lDupli    := .T.
			DbSelectArea("TRF1")
			DbSkip()
		EndDo
		TRF1->(DbCloseArea())
	EndIf

	If lFornece1 <> .T. .Or. lProduto1 <> .T. .Or. lItemnf1  <> .T. .Or. lNFiscal1 <> .T. .Or. lDupli1 <> .T.
		Fwrite(nHandle, "ERRO| CORRIGIR OS ERROS E IMPORTAR NOVAMENTE." + CRLF)
		FClose(nHandle)
		MsgAlert("***    Existem erros no arquivo favor verificar o log.txt     ***")
	Else
		MsgAlert("***    Importação Realizada com Sucesso!!!")
		Fwrite(nHandle, "SLAAGR10 - IMPORTACAO REALIZADA COM SUCESSO." + CRLF)
		FClose(nHandle)
	EndIf

	lFornece1 := .T.
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
User Function SLACapaA()

	Local cTRF1 := ""

	cTRF1:= " select  nf.numero_nota    as F1_DOC    , cast(nf.serie as varchar(3)) F1_SERIE, cast(nf.mlid as varchar(20)) as F1_MLID, "
	cTRF1+= "         nf.data_emissao   as F1_DTDIGIT, nf.data_saida as F1_EMISSAO,     nf.valor_frete  as F1_FRETE,"
	cTRF1+= "         nf.valor_outr_des as F1_DESPESA, nf.base_icms      as F1_BASEICM, nf.valor_icms   as F1_VALICM,"
	//cTRF1+= "         nf.total_produto  as F1_VALMERC, "
	cTRF1+= "         case coalesce(nf.total_produto,0)  "
	cTRF1+= "            when 0 then nf.total_servico    "
	cTRF1+= "            else nf.total_produto           "
	cTRF1+= "         end as F1_VALMERC,                 "
	cTRF1+= "         nf.valor_desconto as F1_DESCONT, nf.peso_liquido as F1_PESOL,"
	cTRF1+= "         nf.tipo_frete     as F1_TPFRETE, nf.valor_seguro,                 nf.grid         as F1_GRID , nf.tipo as F1_TIPO, "
	cTRF1+= "         nf.destinatario                , nf.empresa                     , cast(nf.cpf as varchar(20)) F1_CGC, "
	cTRF1+= "         cast(empresa.cpf as varchar(20)) DESTINO, cast(nf.modelo as varchar(5)) MODELO, cast(nf.nome AS varchar(50)) F1_DESC,   "
	cTRF1+= "         nf.base_subst     as F1_BRICMS , nf.valor_subst as F1_ICMSRET, cast(replace(nf.cfop,'.','') as varchar (20)) as F1_CFO, "
	cTRF1+= "         case when nf.modelo = '55' then (select cast(nfe.chave_acesso as varchar(50)) from nfe where nfe.nota_fiscal = nf.grid) "
	cTRF1+= "            when nf.modelo = '57' then (select cast(cte.chave_acesso as varchar(50)) from cte where cte.nota_fiscal = nf.grid)   "
	cTRF1+= "            else ''        "
	cTRF1+= "         end as F1_CHVNFE, "
	cTRF1+= "	      case              "
	cTRF1+= "            when nf.destinatario is null then (select np.codigo from pessoa np where np.grid = nf.pessoa) "
	cTRF1+= "            else (select nfp.pessoa from nota_fiscal_pessoa nfp where nfp.grid = nf.destinatario)         "
	cTRF1+= "         end as F1_FORNECE,   "
	cTRF1+= "         nf.base_iss,             nf.valor_iss  F1_ISS,          nf.base_irrf F1_BASEIR,            nf.valor_irrf F1_VALIRF, "
	cTRF1+= "         nf.base_csll F1_BASCSLL, nf.valor_csll F1_VALCSLL,      nf.base_inss F1_BASEINS,           nf.valor_inss F1_INSS,   "
	cTRF1+= "         nf.valor_ipi F1_VALIPI,  nf.valor_retido_pis F1_VALPIS, nf.valor_retido_cofins F1_VALCOFI, cast(coalesce(nf.finalidade,'N') as varchar(1)) F1_TIPN, "
	cTRF1+= "         nf.valor_nota F1_VALBRUT  "
	cTRF1+= "    from nota_fiscal nf "
	//cTRF1+= "       join nota_fiscal_pessoa nfp on (nfp.grid = nf.destinatario) "
	cTRF1+= "         join empresa on (empresa.grid = nf.empresa) "
	//cTRF1+= "       join nfe nt on (nt.nota_fiscal = nf.grid) "
	cTRF1+= "   where nf.data_emissao between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"'  and nf.tipo in ('C','D','E') "
	cTRF1+= "     and nf.numero_nota > -1                                                                                 "
	cTRF1+= "     and nf.situacao <> 'C'                                                                                  "
	//cTRF1+= "     and nf.hora_saida < (now() - interval '24 hour')                                                        "
	//cTRF1+= "     and nf.hora_saida < (select now() - interval '24 hour')                                                 "
	If !Empty(Alltrim(MV_PAR03))
		cTRF1+= " and nf.numero_nota = '"+Alltrim(cValToChar(Val(MV_PAR03)))+"' "
	EndIf
	If !Empty(Alltrim(MV_PAR04))
		cTRF1+= " and nf.serie = '"+Alltrim(MV_PAR04)+"'  "
	EndIf
	If !Empty(Alltrim(cFilAte))
		cTRF1+= " and empresa.cpf = '"+cFilAte+"' "
	Else
		cTRF1+= " and empresa.cpf = '"+cFilDe+"' "
	EndIf
	If !Empty(Alltrim(MV_PAR06))
		CTRF1+= " and nf.cpf = '"+cPessoa+"' "
	EndIf
	cTRF1+= " order by nf.data_emissao"

	If Select("TRF1") > 0
		TRF1->(DbCloseArea())
	EndIF

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRF1 ), "TRF1", .F., .T.)

Return ()

//------------------------------------------+
// BUSCA INFORMAÇÃO DOS ITENS DA NOTA       |
//------------------------------------------+
User Function SLAItemA ()

	Local cTRD1:= ""

	cTRD1:= " select nfp.produto        as D1_PRODUTO, nfp.preco_unit     as D1_VUNIT  , nfp.valor          as D1_TOTAL , nfp.quantidade    as D1_QUANT,   "
	cTRD1+= "        nfp.perc_desconto  as D1_DESC   , nfp.aliquota_icms  as D1_ALIQ   , nf.numero_nota     as D1_DOC,     "
	cTRD1+= "        nf.data_emissao    as D1_EMISSAO, cast(nf.serie  as varchar(3)) D1_SERIE, nfp.perc_red_base_icms   , nfp.valor_subst   as D1_ICMSRET, "
	cTRD1+= "        nfp.base_icms      as D1_BASEICM, nfp.valor_frete    as D1_VALFRE,  nfp.valor_seguro   as D1_SEGURO, "
	//cTRD1+= "        case                                                              "
	//cTRD1+= "          when nf.pessoa = 9906    then round(((nfp.valor/nf.total_produto) * nf.valor_desconto),5) "
	//cTRD1+= "          when nf.pessoa = 11981   then round(((nfp.valor/nf.total_produto) * nf.valor_desconto),5) "
	//cTRD1+= "          when nf.pessoa = 12715   then round(((nfp.valor/nf.total_produto) * nf.valor_desconto),5) "
	//cTRD1+= "          when nf.pessoa = 11068   then round(((nfp.valor/nf.total_produto) * nf.valor_desconto),5) "
	//cTRD1+= "          when nf.pessoa = 3278414 then round(((nfp.valor/nf.total_produto) * nf.valor_desconto),5) "
	//cTRD1+= "          else nfp.valor_desconto  "
	//cTRD1+= "        end as D1_VALDESC,       "
	cTRD1+= "        nfp.valor_desconto as D1_VALDESC, nfp.valor_outr_des as D1_DESPESA, cast(nfp.cst as varchar(3)) as D1_CLASFIS, "
	cTRD1+= "        round(((nfp.valor/case coalesce(nf.total_produto,0) when 0 then nf.total_servico else nf.total_produto end) * nf.valor_desconto),5) as D1_VALRAT,  "
	cTRD1+= "        nfp.valor_ipi      as D1_VALIPI , nfp.aliquota_ipi as D1_IPI,    nf.empresa as F1_EMPRESA, cast(replace(nfp.cfop,'.','') as varchar (20)) D1_CF, "
	cTRD1+= "        nfp.valor_icms     as D1_VALICMS, nfp.base_subst   as D1_BRICMS, cast(coalesce(nf.finalidade,'N') as varchar(1)) D1_TIPN,    "
	cTRD1+= "        cast(p.codigo      as varchar(20)) as PRODUTO, cast(p.nome as varchar (50)) DESCRICAO, nfp.numero_item  as D1_ITEM, "
	cTRD1+= "        case coalesce(nf.valor_retido_pis,0) when 0 then nfp.base_pis     else nfp.valor end as D1_BASEPIS, "
	cTRD1+= "        case coalesce(nf.valor_retido_pis,0) when 0 then nfp.aliquota_pis else 0         end as D1_ALQPIS,  nf.valor_retido_pis    as D1_VALPIS, "
	cTRD1+= "        case coalesce(nf.valor_retido_cofins,0) when 0 then nfp.base_cofins else nfp.valor end as D1_BASECOF, "
	cTRD1+= "        case coalesce(nf.valor_retido_cofins,0) when 0 then nfp.aliquota_cofins else 0     end as D1_ALQCOF,  nf.valor_retido_cofins as D1_VALCOF, "
	cTRD1+= "        case coalesce(nf.valor_csll,0) when 0 then nfp.base_csll     else nfp.valor end as D1_BASECSL, "
	cTRD1+= "        case coalesce(nf.valor_csll,0) when 0 then nfp.aliquota_csll else 0         end as D1_ALQCSL,  nf.valor_csll as D1_VALCSL, "
	cTRD1+= "        case coalesce(nf.valor_iss,0) when 0 then nfp.base_iss     else nfp.valor end as D1_BASEISS, "
	cTRD1+= "        case coalesce(nf.valor_iss,0) when 0 then nfp.aliquota_iss else 0         end as D1_ALIQISS, nf.valor_iss    as D1_VALISS, "
	cTRD1+= "        case coalesce(nf.valor_irrf,0) when 0 then nfp.base_irrf     else nfp.valor end as D1_BASEIRR, "
	cTRD1+= "        case coalesce(nf.valor_irrf,0) when 0 then nfp.aliquota_irrf else 0         end as D1_ALIQIRR, nf.valor_irrf as D1_VALIRR, "
	cTRD1+= "        case coalesce(nf.valor_inss,0) when 0 then nfp.base_inss     else nfp.valor end as D1_BASEINS, "
	cTRD1+= "        case coalesce(nf.valor_inss,0) when 0 then nfp.aliquota_inss else 0         end as D1_ALIQINS, nf.valor_inss as D1_VALINS, "
	cTRD1+= "        COALESCE((select cast(natureza_op.codigo as varchar) from natureza_op where natureza_op.grid = nf.natureza_op), '') as NAT_OP "
	cTRD1+= "   from nota_fiscal_produto nfp join nota_fiscal nf on (nf.grid = nfp.nota_fiscal) "
	cTRD1+= "        join produto p on(p.grid = nfp.produto) "
	cTRD1+= "        join empresa on (empresa.grid = nf.empresa) "
	cTRD1+= "  where nfp.nota_fiscal = '"+cValToChar(cNotaFis)+"' " //  and nf.tipo = 'C' "
	//cTRD1+= " and nf.data_emissao between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"' and nf.tipo = 'C'  "
	cTRD1+= "  order by nfp.numero_item "

	If Select("TRD1") > 0
		TRD1->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRD1), "TRD1", .F., .T.)

Return()

//------------------------------------------+
// BUSCA INFORMAÇÃO DO FORNECEDOR           |
//------------------------------------------+
User Function SLAFornA()

	Local cTRA2 := ""

	cTRA2:= " select p.codigo        as A2_COD,                   cast(p.nome    as varchar(50)) A2_NOME  , cast(p.nome_reduzido as varchar(50)) A2_NREDUZ, "
	cTRA2+= "        cast(p.endereco as varchar (50)) A2_END,     cast(p.bairro  as varchar(50)) A2_BAIRRO, cast(p.cidade        as varchar(50)) A2_MUN,    "
	cTRA2+= "        cast(p.estado   as varchar  (2)) A2_UF ,     cast(p.cep     as varchar(11)) A2_CEP   , cast(p.tipo_pessoa   as varchar(50)) A2_TIPO,   "
	cTRA2+= "        cast(p.cpf      as varchar (20)) A2_CGC,     cast(null      as varchar (3)) A2_DDD   , cast(p.fone          as varchar(20)) A2_TEL,    "
	cTRA2+= "        cast(p.contato  as varchar (45)) A2_CONTATO, cast(inscr_est as varchar(20)) A2_INSCR , cast(p.municipio     as varchar (7)) A2_COD_MUN "
	cTRA2+= "   from pessoa p "
	cTRA2+= "  where p.cpf = '"+Alltrim(TRF1->F1_CGC)+"' "

	If Select("TRA2") > 0
		TRA2->(DbCloseArea())
	EndIF
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRA2), "TRA2", .F., .T.)

Return()

//------------------------------------------+
// BUSCA INFORMAÇÃO DO PRODUTO              |
//------------------------------------------+
User Function SLAProdA()

	Local cTRB1    := ""

	cTRB1:=  " select cast(produto.codigo               as varchar(255)) B1_PRODUTO, "
	cTRB1+=  "        cast(produto.nome                 as varchar(255)) B1_DESC, "
	cTRB1+=  "        produto.tipo                      as B1_TIPO, "
	cTRB1+=  "        grupo_produto.codigo              as B1_GRUPO, "
	cTRB1+=  "        cast(produto.unid_med             as varchar(255)) B1_UM, "
	cTRB1+=  "        cast(grupo_produto.nome           as varchar(255)) B1_NOMEG, "
	cTRB1+=  "        cast(produto.codigo_ncm           as varchar(255)) B1_POSIPI, "
	cTRB1+=  "        cast(produto.grid                 as varchar(255)) B1_GRID, "
	cTRB1+=  "        cast(produto.conta_estoque        as varchar (20)) B1_CONTA, "
	cTRB1+=  "        cast(replace(produto.cest,'.','') as varchar (20)) B1_CEST "
	cTRB1+=  "   from produto "
	cTRB1+=  "        join grupo_produto on (grupo_produto.grid = produto.grupo) "
	cTRB1+=  " where produto.grid = '" + cValToChar(cProduto) + "'"

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRB1), "TRB1", .F., .T.)

Return ()

//------------------------------------------+
// BUSCA INFORMAÇÃO DA DUPLICATA            |
//------------------------------------------+
User Function SLADuplA ()

	Local cTRE2 := ""

	cTRE2:= "  select mm.codigo AS CODNAT, cast(split_part(m.documento, '/', 1)as varchar(10)) E2_NUM , p.codigo, e.codigo, m.data  AS E2_EMISSAO, "
	cTRE2+= "         split_part(cast(m.documento as varchar(10)), '/', 2) E2_PARCELA, "
	cTRE2+= "         m.vencto AS E2_VENCTO, m.valor AS E2_VALOR,           "
	cTRE2+= "         cast(mm.nome  AS varchar(50)) E2_HIST, cast(p.cpf  as varchar (20)) E2_CNPJ, m.empresa, "
	cTRE2+= "         cast(split_part(cc.codigo, '.', 2)as varchar(9)) D1_CC, cc.nome "//Centro de Custo
	cTRE2+= "    from movto m "
	cTRE2+= "        join motivo_movto mm on (mm.grid = m.motivo and mm.tipo_movto = 1)"
	cTRE2+= "        join pessoa p  on (p.grid = m.pessoa) "
	cTRE2+= "        join empresa e on (e.grid = m.empresa) "
	cTRE2+= "        left join movto_centro_custo mcc on (mcc.movto = m.grid) and mcc.perc_rateio = 100 " //Centro de Custo
	cTRE2+= "        left join centro_custo cc on (mcc.centro_custo = cc.grid) "//Centro de Custo
	cTRE2+= "   where split_part(cast(m.documento as varchar(10)), '/', 1) = '"+cValToChar(TRF1->F1_DOC)+"'" /* nota_fiscal.numero_nota */
	cTRE2+= "     and m.conta_creditar LIKE '2.1.%'       "
	cTRE2+= "     and p.cpf = '"+ALLTRIM(TRF1->F1_CGC)+"' "
	cTRE2+= "     and m.empresa = '"+Alltrim(Str(TRF1->EMPRESA))+"' "
	
	If !Empty(ALLTRIM(TRF1->F1_MLID))
	  cTRE2+= "     and m.mlid = '"+ALLTRIM(TRF1->F1_MLID)+"' "
	EndIf
	
    cTRE2+=	"   order by m.vencto "

	If Select("TRE2") > 0
		TRE2->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRE2), "TRE2", .F., .T.)

Return()

//------------------------------------------+
// GRAVA A INFORMAÇÃO DO PRODUTO            |
//------------------------------------------+
User Function GRVProdA()
	Private cTipo   := ""
	Private cGrupo  := ""
	Private _cProd  := ""
	Private _cDescP := ""
	Private _cConta := SPACE(20)

	If Alltrim(TRB1->B1_GRID) == Alltrim(cValToChar(cProduto))
		// BUSCA OS CONTA DO PRODUTO
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
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
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
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
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
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
			cQb1:= " SELECT B1_COD FROM " + RETSQLNAME("SB1") + " (NOLOCK) "
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
				SB1->B1_CEST   := TRB1->B1_CEST
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

	cQuery := " SELECT * FROM " + RETSQLNAME("SB1") + " (NOLOCK) "
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
// GRAVA INFORMAÇÃO DO FORNECEDOR           |
//------------------------------------------+
User Function GRVFornA()

	Private cNum := ""
	Private cCEP := Alltrim(TRA2->A2_CEP)

	DbSelectArea("TRA2")
	TRA2->(DbGoTop())
	While TRA2->(!EOF())
		oXagCon:ConecPRT()
		If lFornece
			DbSelectArea("SA2")
			DbSetOrder(3)

			/*CONOUT('cCGC')
			CONOUT(cCGC)
			CONOUT(TRA2->A2_NREDUZ)
			CONOUT(TRF1->F1_DOC)
			conout(TRF1->F1_SERIE)
			conout(cFilant)
			conout(cEmpant) */

			If !DbSeek(xFilial("SA2")+cCGC)
				cCEP := STRTRAN(cCEP,".","")
				cCEP := STRTRAN(cCEP,"-","")
				cCEP := STRTRAN(cCEP,"/","")

				//Cria a nova conta para Fornecedor
				_cConta:= U_AGR10CON(NoAcento(AnsiToOem(IIf (Alltrim(TRA2->A2_NOME) <> "", TRA2->A2_NOME, TRA2->A2_NREDUZ))),"SA2")

				DbSelectArea("SA2")
				Reclock("SA2",.T.)
				SA2->A2_CLASSIF    := "00"
				SA2->A2_COD        := GETSXENUM('SA2','A2_COD') //NextNumero("SA2",1,"A2_COD",.T., )
				ConfirmSX8()
				//conout(SA2->A2_COD)

                SA2->A2_FILIAL     := xFilial('SA2')
				SA2->A2_LOJA       := "01"
				SA2->A2_NOME       := TRA2->A2_NOME
				SA2->A2_NREDUZ     := IIf (Alltrim(TRA2->A2_NREDUZ) = "", TRA2->A2_NOME, TRA2->A2_NREDUZ)
				SA2->A2_CEP        := cCEP
				SA2->A2_END        := TRA2->A2_END
				SA2->A2_BAIRRO     := TRA2->A2_BAIRRO
				SA2->A2_EST        := TRA2->A2_UF
				SA2->A2_MUN        := TRA2->A2_MUN
				SA2->A2_TIPO       := TRA2->A2_TIPO
				SA2->A2_INSCR      := TRA2->A2_INSCR
				SA2->A2_CGC        := cCGC
				SA2->A2_DDD        := TRA2->A2_DDD
				SA2->A2_TEL        := TRA2->A2_TEL
				SA2->A2_CONTATO    := TRA2->A2_CONTATO
				SA2->A2_COD_MUN    := SubStr(TRA2->A2_COD_MUN,3,7)
				SA2->A2_CONTA      := _cConta //Cadastra nova conta para Fornecer

				SA2->(MsUnlock())
			EndIf
			FWrite(nHandle, "CADASTRO FORNECEDOR | AVISO | COD FORNEC "+cCGC+ " | DESCRICAO "+ TRA2->A2_NOME + " | GRAVADO" +CRLF)
		Else
			Fwrite(nHandle, "CADASTRO FORNECEDOR | ERRO  | COD FORNEC "+cCGC+ " | DESCRICAO "+ TRA2->A2_NOME + " | FORNECEDOR NAO CADASTRADO"+ CRLF)
			lFornece1 := .F.
			lFornece  := .F.
		EndIf
		DbCloseArea("SA2")
		DbSelectArea("TRA2")
		DbSkip()
	EndDo
	DbCloseArea("TRA2")

Return()

//------------------------------------------+
// GRAVA INFORMAÇÃO DO CLIENTE - DEVOLUCAO  |
//------------------------------------------+
User Function GRVClieA()

	Private cNum := ""
	Private cCEP := Alltrim(TRA2->A2_CEP) 

	DbSelectArea("TRA2")
	TRA2->(DbGoTop())
	While TRA2->(!EOF())
		oXagCon:ConecPRT()
		If lFornece
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
				SA1->A1_NOME       := TRA2->A2_NOME
				SA1->A1_NREDUZ     := IIf (Alltrim(TRA2->A2_NREDUZ) = "", TRA2->A2_NOME, TRA2->A2_NREDUZ)
				SA1->A1_CEP        := cCEP
				SA1->A1_END        := TRA2->A2_END
				SA1->A1_BAIRRO     := TRA2->A2_BAIRRO
				SA1->A1_EST        := TRA2->A2_UF
				SA1->A1_MUN        := TRA2->A2_MUN
				SA1->A1_TIPO       := TRA2->A2_TIPO
				SA1->A1_INSCR      := TRA2->A2_INSCR
				SA1->A1_CGC        := cCGC
				SA1->A1_DDD        := TRA2->A2_DDD
				SA1->A1_TEL        := TRA2->A2_TEL
				SA1->A1_CONTATO    := TRA2->A2_CONTATO
				SA1->A1_COD_MUN    := SubStr(TRA2->A2_COD_MUN,3,7)
				SA1->(MsUnlock())
			EndIf
			Fwrite(nHandle, "CADASTRO DE CLIENTE | AVISO  | CLIENTE " +cCGC+ " | DESCRICAO "+ TRA2->A2_NOME + " | CLIENTE GRAVADO DE NOTA DEVOL. " + CRLF)
			//lFornece  := .F.
			//lFornece1 := .F.
			//else
			//  FWrite(nHandle, "CADASTRO DE CLIENTE | AVISO | CLIENTE "+SA1->A1_COD+"/"+SA1->A1_LOJA+ " - " +cCGC+ " | DESCRICAO "+ TRA2->A2_NOME + " | CLIENTE JA CADASTRADO." + CRLF)
			//EndIf
		Else
			Fwrite(nHandle, "CADASTRO CLIENTE | ERRO  | CLIENTE "+cCGC+ " | DESCRICAO "+ TRA2->A2_NOME + " | CLIENTE DE NOTA DEVOL. NAO CADASTRADO"+ CRLF)
			lFornece1 := .F.
			lFornece  := .F.
		EndIf
		DbCloseArea("SA1")
		DbSelectArea("TRA2")
		DbSkip()
	EndDo
	DbCloseArea("TRA2")

Return()

//------------------------------------------+
// GRAVA INFORMAÇÃO DA CAPA DA NOTA         |
//------------------------------------------+
User Function GRVCapaA(cCNPJ)

	Local   cQry3   := ""
	Private cCodFor := ""
	Private cLojaFor:= ""
	Private cEstFor := ""
	Private lSF3    := .F.
	Private cTipoNota   := ""
	Private cPrefixoDoc := _cXFilial+SubStr((TRF1->F1_SERIE),1,3) // ribas filial + serie

	cCNPJ := ALLTRIM(TRF1->F1_CGC)
	cCNPJ := STRTRAN(cCnpj,".","")
	cCNPJ := STRTRAN(cCnpj,"-","")
	cCNPJ := STRTRAN(cCnpj,"/","")

	oXagCon:ConecPRT()

	if TRF1->F1_TIPN <> "D"
		DbSelectArea("SA2")
		DbSetOrder(3)
		If DbSeek(xFilial("SA2")+cCNPJ)
			cCodFor := SA2->A2_COD
			cLojaFor:= SA2->A2_LOJA
			cEstFor := SA2->A2_EST
		EndIf
	else
		DbSelectArea("SA1")
		DbSetOrder(3)
		If DbSeek(xFilial("SA1")+cCNPJ)
			cCodFor := SA1->A1_COD
			cLojaFor:= SA1->A1_LOJA
			cEstFor := SA1->A1_EST
		EndIf
	endif

	cDocumento:= cValtoChar(StrZero(TRF1->F1_DOC,9))
	cParEspec:= "NF"

	// BUSCA MODELO DA NF
	cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
	cQuery += " WHERE ZZ9_TABELA = '04' AND ZZ9_CAMP1 = '"+(Alltrim(TRF1->MODELO))+"' AND ZZ9_CAMP3 = 'E' "

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

	//cTipoNota :=  Alltrim(TRF1->F1_TIPN)
	//if Alltrim(TRF1->F1_TIPN) <> "D"
	//  cTipoNota := "N"
	//endif

	DbSelectArea("SF1")
	DbSetOrder(1)
	If !DbSeek(_cXFilial+Alltrim(cDocumento)+Alltrim(cValTochar(TRF1->F1_SERIE))+Alltrim(cCodFor)+Alltrim(cLojaFor)+TRF1->F1_TIPN)
		DbSelectArea("SF1")
		Reclock("SF1",.T.)
		SF1->F1_FILIAL  := _cXFilial
		SF1->F1_DOC     := Alltrim(cDocumento)
		SF1->F1_SERIE   := Alltrim(cValTochar(TRF1->F1_SERIE))
		SF1->F1_EMISSAO := TRF1->F1_EMISSAO
		//SF1->F1_DTLANC  := TRF1->F1_EMISSAO
		SF1->F1_DTDIGIT := TRF1->F1_DTDIGIT //TRF1->F1_EMISSAO
		SF1->F1_RECBMTO := TRF1->F1_DTDIGIT //TRF1->F1_EMISSAO
		SF1->F1_TIPO    := TRF1->F1_TIPN
		SF1->F1_DUPL    := Alltrim(cDocumento)
		SF1->F1_FORNECE := cCodFor
		SF1->F1_LOJA    := cLojaFor
		SF1->F1_EST     := cEstFor
		SF1->F1_DUPL    := Alltrim(cDocumento)
		SF1->F1_ESPECIE := cParEspec
		SF1->F1_COND    := "001"
		SF1->F1_FRETE   := TRF1->F1_FRETE
		SF1->F1_DESPESA := TRF1->F1_DESPESA
		SF1->F1_BASEICM := TRF1->F1_BASEICM
		SF1->F1_VALICM  := TRF1->F1_VALICM
		SF1->F1_VALMERC := TRF1->F1_VALMERC
		SF1->F1_DESCONT := TRF1->F1_DESCONT
		SF1->F1_PESOL   := TRF1->F1_PESOL
		SF1->F1_CHVNFE  := TRF1->F1_CHVNFE
		SF1->F1_STATUS  := cStatus //"A"
		SF1->F1_FORMUL  := "N"
		/* incluido */
		SF1->F1_BRICMS  := TRF1->F1_BRICMS
		SF1->F1_ICMSRET := TRF1->F1_ICMSRET
		SF1->F1_ISS     := TRF1->F1_ISS
		SF1->F1_BASEIR  := TRF1->F1_BASEIR
		SF1->F1_VALIRF  := TRF1->F1_VALIRF
		SF1->F1_BASCSLL := TRF1->F1_BASCSLL
		SF1->F1_VALCSLL := TRF1->F1_VALCSLL
		SF1->F1_BASEINS := TRF1->F1_BASEINS
		SF1->F1_INSS    := TRF1->F1_INSS
		SF1->F1_VALIPI  := TRF1->F1_VALIPI
		SF1->F1_VALPIS  := TRF1->F1_VALPIS
		SF1->F1_VALCOFI := TRF1->F1_VALCOFI
		SF1->F1_ORIIMP  := "SLAARG10"
		SF1->F1_VALBRUT := TRF1->F1_VALBRUT
		SF1->F1_PREFIXO := cPrefixoDoc

		cValIss  := TRF1->F1_ISS
		cValIrr  := TRF1->F1_VALIRF
		cValInss := TRF1->F1_INSS
		cValPis  := TRF1->F1_VALPIS
		cValCof  := TRF1->F1_VALCOFI
		cValCsl  := TRF1->F1_VALCSLL

		SF1->(MsUnlock())
		DbCloseArea("SF1")
		FWrite(nHandle, "CAPA DA NOTA        | AVISO | NUM NOTA   "+Alltrim(cDocumento)+ " FORNEC "+ cCodFor  + " | GRAVADA COM SUCESSO" + CRLF)
	EndIf

Return()

//------------------------------------------+
// GRAVA INFORMAÇÃO DOS ITENS DA NOTA       |
//------------------------------------------+
User Function GRVItemA(cCNPJ)

	Local cQuery     := ""
	Local cZZ9_CAMP8 := ""
	Local aTemRateio := {}
	Local cD1_RATEIO := ""
	//Local nSumRateio := 0 
	Private cCodFor  := ""
	Private cLojaFor := ""
	Private cPj      := ""
	Private cTES     := ""
	Private cCfop    := ""
	Private cConta   := ""
	Private lSD1     := .F.
	Private _cProd   := ""
	Private cNumSeq  := Space(TamSx3('D1_NUMSEQ')[1])

	_cProd := Alltrim(TRD1->PRODUTO)
	cDocd1 := cValtoChar(StrZero(TRD1->D1_DOC,9))

	cPj := ALLTRIM(cCNPJ)
	cPj := STRTRAN(cPj,".","")
	cPj := STRTRAN(cPj,"-","")
	cPj := STRTRAN(cPj,"/","")

	oXagCon:ConecPRT()
	if TRD1->D1_TIPN <> "D"
		DbSelectArea("SA2")
		DbSetOrder(3)
		If DbSeek(xFilial("SA2")+cPj)
			cCodFor := SA2->A2_COD
			cLojaFor:= SA2->A2_LOJA
		EndIf
	else
		DbSelectArea("SA1")
		DbSetOrder(3)
		If DbSeek(xFilial("SA1")+cPj)
			cCodFor := SA1->A1_COD
			cLojaFor:= SA1->A1_LOJA
		EndIf
	endif

	cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
	cQuery += " WHERE ZZ9_TABELA = 'B1' AND ZZ9_CAMP4 = '"+(Alltrim(TRD1->PRODUTO))+"' "

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
	cQry += " FROM " + RetSQLName("SD1") + " (NOLOCK) "
	cQry += " WHERE "+RetSQLName("SD1")+".D_E_L_E_T_ = '' "
	cQry += " AND D1_FILIAL = '"+_cXFilial+"' AND D1_DOC = '"+Alltrim(cDocd1)+"'"
	cQry += " AND D1_SERIE = '"+Alltrim(cValToChar(TRD1->D1_SERIE))+"' AND D1_FORNECE = '"+Alltrim(cCodFor)+"' "
	cQry += " AND D1_LOJA = '"+Alltrim(cLojaFor)+"' "
	cQry += " AND D1_COD = '"+Alltrim(_cProd)+"' "
	cQry += " AND (D1_ITEM = '"+cValToChar(TRD1->D1_ITEM)+"' OR D1_ITEM = '"+cValToChar(StrZero(TRD1->D1_ITEM,4))+"') "

	If (Select ("QRY")<> 0)
		QRY->(DbCloseArea())
	EndIf
	TcQuery cQry New Alias "QRY"

	DbSelectArea("QRY")
	DbGoTop()
	While !EOF()
		lSD1:= .T.
		QRY->(DbSkip())
	EndDo

	cUM      := ""
	cCConta  := ""
	cTP      := ""
	cGrupoD1 := ""
	cLocal   := ""
	cCodISS  := ""

	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+PADR(Alltrim(_cProd),((TamSx3('B1_COD')[1])))) //DbSeek(xFilial("SB1")+Alltrim(_cProd))
		cUM      := SB1->B1_UM
		cCConta  := SB1->B1_CONTA
		cTP      := SB1->B1_TIPO
		cGrupoD1 := SB1->B1_GRUPO
		cLocal   := SB1->B1_LOCPAD
        cCodISS  := SB1->B1_CODISS
	EndIf

	cCfop:= SubStr(TRD1->D1_CF,2,4)
	cTES    := '498'
	cStatus := 'A'

	// BUSCA CFOP
	cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
	cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP7 = 'E' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"'"

	If (Select ("QR05")<> 0)
		QR05->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QR05"

	DbSelectArea("QR05")
	DbGoTop()
	While !EOF()
		cTES:= Alltrim(QR05->ZZ9_CAMP1)

		cZZ9_CAMP8 := QR05->ZZ9_CAMP8
		if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
			cStatus := ''
		endif

		QR05->(DbSkip())
	EndDo
	DbCloseArea("QR05")

	//----------------------------------//
	cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
	cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD1->D1_CLASFIS)+"' AND ZZ9_CAMP7 = 'E' "

	If (Select ("QR05")<> 0)
		QR05->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QR05"

	DbSelectArea("QR05")
	DbGoTop()
	While !EOF()
		cTES:= Alltrim(QR05->ZZ9_CAMP1)

		cZZ9_CAMP8 := QR05->ZZ9_CAMP8
		if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
			cStatus := ''
		endif

		QR05->(DbSkip())
	EndDo
	DbCloseArea("QR05")

	//----------------------------------//
	If TRD1->D1_VALICMS == 0
		//----------------------------------//
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' "
		cQuery += " AND ZZ9_CAMP3  = 'D1_VALICMS==0' AND ZZ9_CAMP7 = 'E' "

		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		DbGoTop()
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

			cZZ9_CAMP8 := QR05->ZZ9_CAMP8
			if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
				cStatus := ''
			endif

			QR05->(DbSkip())
		EndDo
		DbCloseArea("QR05")

		//----------------------------------//
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD1->D1_CLASFIS)+"' "
		cQuery += " AND ZZ9_CAMP3  = 'D1_VALICMS==0' AND ZZ9_CAMP7 = 'E' "
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		DbGoTop()
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

			cZZ9_CAMP8 := QR05->ZZ9_CAMP8
			if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
				cStatus := ''
			endif

			QR05->(DbSkip())
		EndDo
		DbCloseArea("QR05")

	Else

		//----------------------------------//
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"'  "
		cQuery += " AND ZZ9_CAMP4  = 'D1_VALICMS>0' AND ZZ9_CAMP7 = 'E' "
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		DbGoTop()
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

			cZZ9_CAMP8 := QR05->ZZ9_CAMP8
			if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
				cStatus := ''
			endif

			QR05->(DbSkip())
		EndDo
		DbCloseArea("QR05")

		//----------------------------------//
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD1->D1_CLASFIS)+"' "
		cQuery += " AND ZZ9_CAMP4  = 'D1_VALICMS>0' AND ZZ9_CAMP7 = 'E' "
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		DbGoTop()
		While !EOF()
			cTES := Alltrim(QR05->ZZ9_CAMP1)

			cZZ9_CAMP8 := QR05->ZZ9_CAMP8
			if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
				cStatus := ''
			endif

			QR05->(DbSkip())
		EndDo
		DbCloseArea("QR05")
	EndIf
	
	//Spiller - Verifica se a Nota Possui Rateio, Grava array aTemRateio com as informações:
	// [1] - Centro de Custo
	// [2] - % de rateio
	// [3] - Valor Total de Rateio
	aTemRateio := U_SLARATCC()
	If len(aTemRateio) > 1 
		cD1_RATEIO  := "1"
	Else
		cD1_RATEIO  := "2"
	Endif
	
	If !lSD1
		cValDesconto := 0

		cValDesconto := TRD1->D1_VALDESC
		if cParEspec <> "SPED"
			cValDesconto := TRD1->D1_VALRAT
		endif

		DbSelectArea("SD1")
		//    	cNumSeq := ProxNum() // Alterado devido erros com a função ProxNum()
		cNumSeq := GETMV("MV_DOCSEQ")
		cNumSeq := SOMA1(cNumSeq)
		IF GETMV("MV_DOCSEQ") < cNumSeq
			PUTMV("MV_DOCSEQ", cNumSeq)
		ENDIF
		Reclock("SD1",.T.)
		SD1->D1_FILIAL  := _cXFilial
		SD1->D1_ITEM    := cValToChar(StrZero(TRD1->D1_ITEM,4)) //cValToChar(TRD1->D1_ITEM) /* cValToChar(nItem) */
		SD1->D1_COD		:= Alltrim(_cProd)
		SD1->D1_UM      := cUM
		SD1->D1_LOCAL   := cLocal
		SD1->D1_CONTA   := cCConta
		SD1->D1_TES     := cTES
		SD1->D1_TP      := cTP
		SD1->D1_DESCRI  := TRD1->DESCRICAO
		SD1->D1_QUANT   := TRD1->D1_QUANT
		SD1->D1_VUNIT   := TRD1->D1_VUNIT
		SD1->D1_TOTAL   := TRD1->D1_TOTAL
		SD1->D1_CUSTO   := TRD1->D1_TOTAL
		SD1->D1_VALDESC	:= cValDesconto //TRD1->D1_VALDESC
		SD1->D1_FORNECE := cCodFor
		SD1->D1_LOJA    := cLojaFor
		SD1->D1_GRUPO   := cGrupoD1
		SD1->D1_ITEMCTA := _cXFilial//"01"
		SD1->D1_DOC     := Alltrim(cDocd1)
		SD1->D1_EMISSAO := cDtEmissao//TRF1->F1_EMISSAO //TRD1->D1_EMISSAO
		SD1->D1_DTDIGIT := cDtDigit  //TRF1->F1_DTDIGIT //TRD1->D1_EMISSAO
		SD1->D1_SERIE   := Alltrim(cValToChar(TRD1->D1_SERIE))
		SD1->D1_BASEICM := TRD1->D1_BASEICM
		SD1->D1_NUMSEQ  := cNumSeq //SD1->D1_NUMSEQ  := ProxNum() // GETMV("MV_DOCSEQ")
		SD1->D1_TIPO    := TRD1->D1_TIPN //"N"
		SD1->D1_ORIIMP  := "SLAARG10"
		SD1->D1_CF      := TRD1->D1_CF
		SD1->D1_PICM    := TRD1->D1_ALIQ
		SD1->D1_VALICM  := TRD1->D1_VALICMS
		/* incluido */
		SD1->D1_DESC    := TRD1->D1_DESC
		SD1->D1_BRICMS  := TRD1->D1_BRICMS
		SD1->D1_ICMSRET := TRD1->D1_ICMSRET
		SD1->D1_SEGURO  := TRD1->D1_SEGURO
		SD1->D1_VALFRE  := TRD1->D1_VALFRE
		SD1->D1_DESPESA := TRD1->D1_DESPESA
		SD1->D1_BASEIRR := TRD1->D1_BASEIRR
		SD1->D1_ALIQIRR := TRD1->D1_ALIQIRR
		SD1->D1_VALIRR  := TRD1->D1_VALIRR
		SD1->D1_BASEISS := TRD1->D1_BASEISS
		SD1->D1_ALIQISS := TRD1->D1_ALIQISS
		SD1->D1_VALISS  := TRD1->D1_VALISS
		SD1->D1_BASEINS := TRD1->D1_BASEINS
		SD1->D1_ALIQINS := TRD1->D1_ALIQINS
		SD1->D1_VALINS  := TRD1->D1_VALINS
		SD1->D1_VALIPI  := TRD1->D1_VALIPI
		SD1->D1_IPI     := TRD1->D1_IPI
		SD1->D1_CLASFIS := TRD1->D1_CLASFIS
		SD1->D1_BASEPIS := TRD1->D1_BASEPIS
		SD1->D1_ALQPIS  := TRD1->D1_ALQPIS
		SD1->D1_VALPIS  := TRD1->D1_VALPIS
		SD1->D1_BASECOF := TRD1->D1_BASECOF
		SD1->D1_ALQCOF  := TRD1->D1_ALQCOF
		SD1->D1_VALCOF  := TRD1->D1_VALCOF
		SD1->D1_BASECSL := TRD1->D1_BASECSL
		SD1->D1_ALQCSL  := TRD1->D1_ALQCSL
		SD1->D1_VALCSL  := TRD1->D1_VALCSL
        SD1->D1_CODISS  := cCodISS
		SD1->D1_RATEIO  := cD1_RATEIO//"2"
		
		//Grava na tabela SD1 se NÃO for rateado
		if len(aTemRateio) == 1 
			SD1->D1_CC  := aTemRateio[1][1]  
		Endif 
		
		// Caso o Centro de Custo esteja VAZIO, 
		// deverá pegar do padrão da filial
		// Quando utilizado Contas 	
		If alltrim(SD1->D1_CC) == '' .AND. cD1_RATEIO  == "2"
		    cCtaDeb := U_AGR120() //Chama a Função que preenche a Conta no LP
			If substr(ALLTRIM(cCtaDeb),1,2) >= '52'
				SD1->D1_CC  := GetCCPadra(SD1->D1_FILIAL)
		    Endif
		Endif
		/*
		cValIss := cValIss + TRD1->D1_VALISS
		cValIrr := cValIrr + TRD1->D1_VALIRR
		cValPis := cValPis + TRD1->D1_VALPIS
		cValCof := cValCof + TRD1->D1_VALCOF
		cValCsl := cValCsl + TRD1->D1_VALCSL
		*/
		SD1->(MsUnlock())
		//DbCloseArea("SD1")
			
		//Se existir Rateio, Grava tabela SDE
		If cD1_RATEIO == "1" .and. len(aTemRateio) > 1
			SLAGrvRat(aTemRateio)
		Endif
		
		SDE->(DbCloseArea())
		SD1->(DbCloseArea())
		
		FWrite(nHandle, "ITENS DA NOTA       | AVISO | ITEM  "+cValToChar(nItem)+ " | PRODUTO "+ TRD1->PRODUTO +" | NF: "+ Alltrim(cDocd1) + " | GRAVADO" + CRLF)
	Else
		FWrite(nHandle,     "ITENS DA NOTA       | AIVSO | ITEM  "+cValToChar(nItem)+ " | PRODUTO "+ TRD1->PRODUTO +" | NF: "+ Alltrim(cDocd1) + " | ITEM DA NF JA INSERIDO "+ CRLF)
		lItemnf:= .F.

	EndIf
	QRY->(DbCloseArea())

Return()

//------------------------------------------+
// GRAVA INFORMAÇÃO DAS DUPLICATAS          |
//------------------------------------------+
User Function GRVDuplA(cCGC)

	Local  cQuery       := ""
	Local  cSerie       := TRF1->F1_SERIE
	Private cPrefixo	:= _cXFilial+SubStr((TRF1->F1_SERIE),1,3) // ribas filial + serie
	Private lSE2        := .F.
	Private cCodFor     := ""
	Private cCodE2      := ""

	cCPF := ALLTRIM(cCGC)
	cCPF := STRTRAN(cCPF,".","")
	cCPF := STRTRAN(cCPF,"-","")
	cCPF := STRTRAN(cCPF,"/","")

	oXagCon:ConecPRT()
	if TRF1->F1_TIPN <> "D"
		DbSelectArea("SA2")
		DbSetOrder(3)
		If DbSeek(xFilial("SA2")+cCPF)
			cCodFor := SA2->A2_COD
			cLojaFor:= SA2->A2_LOJA
			cNomeFor:= SA2->A2_NOME
		EndIf
	else
		DbSelectArea("SA1")
		DbSetOrder(3)
		If DbSeek(xFilial("SA1")+cCPF)
			cCodFor := SA1->A1_COD
			cLojaFor:= SA1->A1_LOJA
			cNomeFor:= SA1->A1_NOME
		EndIf
	endif

	cDocE2:= cValtoChar(StrZero(TRF1->F1_DOC,9))

	cQuery := " SELECT *"
	cQuery += " FROM "+RetSQLName("SE2") + " (NOLOCK) "
	cQuery += " WHERE "+RetSQLName("SE2")+".D_E_L_E_T_ = ''"
	cQuery += " AND E2_FILIAL = '' AND E2_PREFIXO = '"+Alltrim(cValToChar(cPrefixo))+"' "
	cQuery += " AND E2_NUM = '"+Alltrim(cDocE2)+"' AND  E2_FORNECE = '"+Alltrim(cCodFor)+"' AND E2_LOJA = '"+Alltrim(cLojaFor)+"'"
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
		RecLock("SE2",.T.)
		SE2->E2_PREFIXO		:= Alltrim(cValToChar(cPrefixo))
		SE2->E2_NUM			:= Alltrim(cDocE2)
		SE2->E2_PARCELA  	:= cValToChar(nParcela)
		SE2->E2_FORNECE		:= cCodFor
		SE2->E2_LOJA		:= cLojaFor
		SE2->E2_NOMFOR		:= cNomeFor
		SE2->E2_EMISSAO  	:= cDtEmissao //TRF1->F1_EMISSAO //TRE2->E2_EMISSAO
		SE2->E2_VENCTO 		:= TRE2->E2_VENCTO
		SE2->E2_VENCREA		:= TRE2->E2_VENCTO
		SE2->E2_VALOR		:= TRE2->E2_VALOR //- (cValIss + cValIrr + cValPis + cValCof + cValCsl + cValInss)
		SE2->E2_EMIS1 		:= cDtDigit //TRF1->F1_DTDIGIT //TRE2->E2_EMISSAO
		SE2->E2_HIST		:= TRE2->E2_HIST
		SE2->E2_LA			:= ""
		SE2->E2_SALDO		:= TRE2->E2_VALOR //- (cValIss + cValIrr + cValPis + cValCof + cValCsl + cValInss) //TRE2->E2_VALOR
		SE2->E2_VALLIQ		:= TRE2->E2_VALOR //- (cValIss + cValIrr + cValPis + cValCof + cValCsl + cValInss) //TRE2->E2_VALOR
		SE2->E2_VENCORI		:= TRE2->E2_VENCTO //TRE2->E2_EMISSAO
		SE2->E2_MOEDA		:= 1
		SE2->E2_VLCRUZ		:= TRE2->E2_VALOR //- (cValIss + cValIrr + cValPis + cValCof + cValCsl + cValInss) //TRE2->E2_VALOR
		SE2->E2_ORIGEM		:= "MATA100"
		SE2->E2_TIPO 		:= "NF"
		SE2->E2_ORIIMP  	:= "SLAAGR10"
		SE2->E2_FILORIG		:= _cXFilial
		SE2->E2_MSFIL       := _cXFilial
		SE2->E2_MSEMP       := cEmpAnt
		SE2->E2_NATUREZ  	:= "201010" //CHAMADO 51346 - AGRICOPEL, MUDA VALOR DO TITULO AO ALTERAR CAMPO NATUREZA

		If (Alltrim(cEmpAnt) == "21")
			SE2->E2_FILIAL := _cXFilial
		EndIf

		SE2->E2_INSS    := cValInss/nQtdeReg
		SE2->E2_IRRF    := cValIrr/nQtdeReg
		SE2->E2_VRETIRF := cValIrr/nQtdeReg
		SE2->E2_ISS     := cValIss/nQtdeReg
		SE2->E2_VRETCSL := cValCsl/nQtdeReg
		SE2->E2_CSLL    := cValCsl/nQtdeReg
		SE2->E2_PIS     := cValPis/nQtdeReg
		SE2->E2_COFINS  := cValCof/nQtdeReg
		SE2->E2_BASEPIS := TRE2->E2_VALOR/nQtdeReg
		SE2->E2_BASECOF := TRE2->E2_VALOR/nQtdeReg
		SE2->E2_BASECSL := TRE2->E2_VALOR/nQtdeReg
		SE2->E2_BASEINS := TRE2->E2_VALOR/nQtdeReg

		SE2->(MsUnLock())
		
		FWrite(nHandle, "DUPLICATAS          | AVISO | NUM DUPLICATA "+Alltrim(cDocE2)+ " | FORNEC "+ cCodFor  + " | GRAVADO COM SUCESSO" + CRLF)
	Else
		FWrite(nHandle, "DUPLICATAS          | ERRO  | NUM DUPLICATA "+Alltrim(cDocE2)+ " | FORNEC "+ cCodFor  + " | NAO IMPORTADA, JA EXISTENTE NO MICROSIGA" + CRLF)
		lSE2:= .F.
	EndIf

	// *** Retirado devido a Implementação de Rateio por CC ***
	// Grava Centro de Custo na tabela SD1
	// O Autosystem possui Centro de Custo por Título,
	// e é possível Ratear o Valor, ficou acordado com
	// Alexandre que o Rateio não irá ser utilizado,
	// dessa forma havendo apenas 1 CC por Título
	//If alltrim(TRE2->D1_CC) <> "" 
	//	GravaCC(_cXFilial,cDocE2,cSerie,cCodFor,cLojaFor,alltrim(TRE2->D1_CC))
	//Endif

	//Quando for Motivo 405 deve baixar o título automáticamente
	IF TRE2->CODNAT == 405
			U_SLABXTIT()
	Endif

	SE2->(DbCloseArea())

	cValIss := 0
	cValIrr := 0
	cValPis := 0
	cValCof := 0
	cValCsl := 0

	QRY1->(DbCloseArea())

Return()


//*** Retirado devido a Implementação de Rateio por CC ***
//Grava Centro de Custo na SD1
/*Static Function GravaCC(_xFilial,_xDoc,_xSerie,_xFornece, _xLoja, _xCC )

	Local cQuery := ""

	cQuery += " UPDATE "+RetSqlName('SD1')+" "//SD1"+alltrim(cEmpAnt)+"0 "
	cQuery += " SET D1_CC = '"+_xCC+"' "
	cQuery += " WHERE D1_FILIAL = '"+_xFilial+"' "
	cQuery += " AND D1_DOC = '"+_xDoc+"' "
	cQuery += " AND D1_SERIE= '"+_xSerie+"' "
	cQuery += " AND D1_FORNECE= '"+_xFornece+"' "
	cQuery += " AND D1_LOJA= '"+_xLoja+"' "
	cQuery += " AND D_E_L_E_T_ = '' "

	If (TCSQLExec(cQuery) < 0)
		CONOUT("TCSQLError() " + TCSQLError())
	EndIf

Return*/

//Geração de Conta Contabil automaticamente
User Function AGR10CON(xRazao,xTipo)

	Local nOpcAuto :=0
	Local nX
	Local oCT1
	Local aLog
	Local cLog   := ""
	Local _cConta := ""

	CONOUT('AGR10CON')
	CONOUT(xRazao)
	Default xTipo = "SA2"

	Static __oModelAut //:= NIL //variavel oModel para substituir msexecauto em MVC

	//Se for conta de Fornecedor
	If xTipo ==  "SA2"

		__oModelAut := FWLoadModel('CTBA020')
		nOpcAuto:=3
		__oModelAut:SetOperation(nOpcAuto) // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
		__oModelAut:Activate() //ativa modelo

		DbSelectArea('CT1')
		RegtoMemory('CT1')
		_cConta := ALLTRIM(STR(ProxForn()))
		CONOUT(_cConta)
		oCT1 := __oModelAut:GetModel('CT1MASTER') //Objeto similar enchoice CT1
		oCT1:SETVALUE('CT1_CONTA',_cConta/*'211016859'*/)
		oCT1:SETVALUE('CT1_DESC01',ALLTRIM(xRazao))
		oCT1:SETVALUE('CT1_CLASSE','2')
		oCT1:SETVALUE('CT1_NORMAL' ,'2')
		oCT1:SETVALUE('CT1_BLOQ' ,'2')
		oCT1:SETVALUE('CT1_CVD02','1')
		oCT1:SETVALUE('CT1_CVD03','1')
		oCT1:SETVALUE('CT1_CVD04','1')
		oCT1:SETVALUE('CT1_CVD05','1')
		oCT1:SETVALUE('CT1_CVC02','1')
		oCT1:SETVALUE('CT1_CVC03','1')
		oCT1:SETVALUE('CT1_CVC04','1')
		oCT1:SETVALUE('CT1_CVC05','1') 
		If cEmpant == '44'
			oCT1:SETVALUE('CT1_CTASUP','210101')
		Else
			oCT1:SETVALUE('CT1_CTASUP','21101')
		Endif
		oCT1:SETVALUE('CT1_ACITEM','1')
		oCT1:SETVALUE('CT1_ACCUST','1')
		oCT1:SETVALUE('CT1_ACCLVL','1')
		oCT1:SETVALUE('CT1_AGLSLD','2')
		oCT1:SETVALUE('CT1_RGNV1','200001')
		oCT1:SETVALUE('CT1_CCOBRG','2')
		oCT1:SETVALUE('CT1_ITOBRG','2')
		oCT1:SETVALUE('CT1_CLOBRG','2')
		oCT1:SETVALUE('CT1_LALHIR','2')
		oCT1:SETVALUE('CT1_ACATIV','2')
		oCT1:SETVALUE('CT1_ATOBRG','2')
		oCT1:SETVALUE('CT1_05OBRG','2')
		oCT1:SETVALUE('CT1_PVARC','1')
		oCT1:SETVALUE('CT1_ACET05','2')
		oCT1:SETVALUE('CT1_INTP','1')
		oCT1:SETVALUE('CT1_NTSPED','02')

		DbSelectArea('CVD')
		RegtoMemory('CVD')
		oCVD := __oModelAut:GetModel('CVDDETAIL') //Objeto similar getdados CVD
		oCVD:SETVALUE('CVD_FILIAL' ,xFilial('CVD'))
		oCVD:SETVALUE('CVD_ENTREF','10')
		oCVD:SETVALUE('CVD_CODPLA','003   '/*PadR('2016',Len(CVD->CVD_CODPLA))*/)
		oCVD:SETVALUE('CVD_CTAREF','2.01.01.03.01                 '/*PadR('1.01.01.01.01', Len(CVD->CVD_CTAREF))*/)
		oCVD:SETVALUE('CVD_TPUTIL','A')
		oCVD:SETVALUE('CVD_CLASSE','2')
		oCVD:SETVALUE('CVD_VERSAO','0001'/*PadR('0001',Len(CVD->CVD_VERSAO))*/)
		oCVD:SETVALUE('CVD_NATCTA','02')
		oCVD:SETVALUE('CVD_CTASUP','2.01.01.03                    ')
		//oCVD:SETVALUE('CVD_CUSTO' ,'001'/*PadR('001',Len(CVD->CVD_CUSTO))*/)

		oCTS := __oModelAut:GetModel('CTSDETAIL') //Objeto similar getdados CTS
		DbSelectArea('CTS')
		DbSetOrder(2)
		If DbSeek(xfilial('CTS')+'999'+'0000000502'+'004')
			RegtoMemory('CTS')

			oCTS:SETVALUE('CTS_FILIAL' ,xFilial('CTS'))
			oCTS:SETVALUE('CTS_CODPLA' ,'999')
			oCTS:SETVALUE('CTS_CONTAG' ,'000000000000400500.1')
			oCTS:SETVALUE('CTS_ORDEM' ,'0000000502')
			oCTS:SETVALUE('CTS_IDENT' ,'1')
		Endif

		If __oModelAut:VldData() //validacao dos dados pelo modelo
			__oModelAut:CommitData() //gravacao dos dados
		Else
			aLog := __oModelAut:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData

			//laco para gravar em string cLog conteudo do array aLog
			For nX := 1 to Len(aLog)
				If !Empty(aLog[nX])
					cLog += Alltrim(aLog[nX]) + CRLF
				EndIf
			Next nX

			lMsErroAuto := .T. //seta variavel private como erro
			Conout(cLog)
			//AutoGRLog(cLog) //grava log para exibir com funcao mostraerro
			//mostraerro()
			cConta := ""
		EndIf

		__oModelAut:DeActivate() //desativa modelo
	Else
		//Pendente
		//Não criado ainda inclusão automática para Clientes
		_cConta := ""
	Endif

Return _cConta

//Captura próxima conta Válida
Static Function ProxForn()

	Local cQuery 	:= ""
	Local cAliasQry := "TCT1"

	cQuery += " SELECT MAX(CT1_CONTA)+1 AS CT1_CONTA FROM CT1"+cEmpant+"0 (NOLOCK) "
	If cEmpAnt == '44'
		cQuery += " WHERE CT1_CONTA  LIKE '2101010%' "
	Else
		cQuery += " WHERE CT1_CONTA  LIKE '21101%' "
	Endif
	cQuery += " AND D_E_L_E_T_ = '' "

	If Select(cAliasQry) <> 0
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasQry)

Return (cAliasQry)->CT1_CONTA


//------------------------------------------+
// BUSCA INFORMAÇÃO DE RATEIO POR CC        |
//------------------------------------------+
User Function SLARATCC()

	Local cTRERAT := ""
	Local aRetRAT := {}
	Local nTotalTit := 0 
	Local _i        := 0
	
	oXagCon:ConecATS()

	/*cTRERAT:= "  select cast(split_part(m.documento, '/', 1)as varchar(10)) E2_NUM , p.codigo, e.codigo, m.data  AS E2_EMISSAO, "
	cTRERAT+= "         split_part(cast(m.documento as varchar(10)), '/', 2) E2_PARCELA, "
	cTRERAT+= "         m.vencto AS E2_VENCTO, m.valor AS E2_VALOR,           "
	cTRERAT+= "         cast(mm.nome  AS varchar(50)) E2_HIST, cast(p.cpf  as varchar (20)) E2_CNPJ, m.empresa, "
	cTRERAT+= "         cast(split_part(cc.codigo, '.', 2)as varchar(9)) D1_CC, cc.nome, mcc.valor_rateio AS VALRAT, mcc.perc_rateio PERCRAT "//Centro de Custo
	cTRERAT+= "    from movto m "
	cTRERAT+= "        join motivo_movto mm on (mm.grid = m.motivo and mm.tipo_movto = 1)"
	cTRERAT+= "        join pessoa p  on (p.grid = m.pessoa) "
	cTRERAT+= "        join empresa e on (e.grid = m.empresa) "
	cTRERAT+= "        left join movto_centro_custo mcc on (mcc.movto = m.grid) "//"and mcc.perc_rateio <> 100 " //Centro de Custo
	cTRERAT+= "        left join centro_custo cc on (mcc.centro_custo = cc.grid) "//Centro de Custo
	cTRERAT+= "   where split_part(cast(m.documento as varchar(10)), '/', 1) = '"+cValToChar(TRF1->F1_DOC)+"'" // nota_fiscal.numero_nota 
	cTRERAT+= "     and m.conta_creditar LIKE '2.1.%'       "
	cTRERAT+= "     and p.cpf = '"+ALLTRIM(TRF1->F1_CGC)+"' "
	cTRERAT+= "     and m.empresa = '"+Alltrim(cValtoChar(TRF1->EMPRESA))+"' order by m.vencto"
	*/
    cTRERAT:= "  select "
    cTRERAT+= "         cast(split_part(m.documento, '/', 1)as varchar(10)) E2_NUM,"
    cTRERAT+= "         cast(split_part(cc.codigo, '.', 2)as varchar(9)) D1_CC, "
    cTRERAT+= "         sum( mcc.valor_rateio) AS VALRAT "
    cTRERAT+= "    from movto m    "
    cTRERAT+= "         join motivo_movto mm on (mm.grid = m.motivo and mm.tipo_movto = 1) "       
    cTRERAT+= "         join pessoa p  on (p.grid = m.pessoa)  "       
    cTRERAT+= "         join empresa e on (e.grid = m.empresa)  "       
    cTRERAT+= "         left join movto_centro_custo mcc on (mcc.movto = m.grid)  "       
    cTRERAT+= "         left join centro_custo cc on (mcc.centro_custo = cc.grid) "   
    cTRERAT+= "   where split_part(cast(m.documento as varchar(10)), '/', 1) = '"+cValToChar(TRF1->F1_DOC)+"'" // nota_fiscal.numero_nota 
	cTRERAT+= "     and m.conta_creditar LIKE '2.1.%'       "
	cTRERAT+= "     and p.cpf = '"+ALLTRIM(TRF1->F1_CGC)+"' "
	cTRERAT+= "     and m.empresa = '"+Alltrim(Str(TRF1->EMPRESA))+"' "

	If !Empty(ALLTRIM(TRF1->F1_MLID))	 
       cTRERAT+= "     and m.mlid = '"+ALLTRIM(TRF1->F1_MLID)+"' "
    EndIf
    cTRERAT+= "   group by D1_CC,E2_NUM "
	
	If Select("TRERAT") > 0
		TRERAT->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRERAT), "TRERAT", .F., .T.)
	
	//Grava dados do título
	While TRERAT->(!eof())
		
		If TRERAT->VALRAT > 0 
			AADD(aRetRAT,{TRERAT->D1_CC, 0/*TRERAT->PERCRAT*/,TRERAT->VALRAT })
			//AADD(aRetRAT,{TRERAT->D1_CC, TRERAT->PERCRAT,TRERAT->VALRAT })
		Endif	
		nTotalTit += TRERAT->VALRAT //Total da Nota
		TRERAT->(dbskip())
	Enddo
	
	// Calcula % de rateio, essa alteração foi necessária devido a existir rateio por parcela
	// para obter o % total da nota é realizado (valor / total) * 100
	For _i := 1 to len(aRetRAT)
		aRetRAT[_i][2] := Round( (aRetRAT[_i][3] / nTotalTit) * 100  ,2)	
	Next _i  
	
	oXagCon:ConecPRT()
		
Return aRetRAT


//------------------------------------------+
// GRAVA RATEIO POR CC NA TABELA SDE        |
//------------------------------------------+
Static Function SLAGrvRat(xTemRateio)

	Local _iRat := 0 
	
	//Varre Array de Rateio e Grava Tabela SDE
	For _iRat := 1 to len(xTemRateio)				
		DbSelectarea('SDE')
		Dbsetorder(1)	
		If _iRat == 1//Se for primeiro registro Verifica se já Existe na Tabela 
			If Dbseek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM)
				Exit
			Endif
		Endif 
		//Grava tabela SDE
		Reclock('SDE',.T.)
			DE_FILIAL  := SD1->D1_FILIAL
			DE_DOC	   := SD1->D1_DOC
			DE_SERIE   := SD1->D1_SERIE	
			DE_FORNECE := SD1->D1_FORNECE
			DE_LOJA	   := SD1->D1_LOJA
			DE_ITEMNF  := SD1->D1_ITEM
			DE_ITEM	   := cValToChar(StrZero(_iRat,2)) 
			DE_PERC	   := xTemRateio[_iRat][2]//%Rateio
			DE_CC	   := xTemRateio[_iRat][1]//Centro de Custo
			DE_CONTA   := SD1->D1_CONTA
			DE_ITEMCTA := SD1->D1_ITEMCTA
			DE_SDOC    := SD1->D1_SERIE	
			DE_CUSTO1  := ROUND( SD1->D1_CUSTO *(xTemRateio[_iRat][2]/100 ),2)
			//DE_CUSTO2//DE_CUSTO3//DE_CUSTO4//DE_CUSTO5//DE_CLVL
		SDE->(Msunlock())				
	Next _iRat

Return                  

      
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


//Realiza a Baixa do título
User Function SLABXTIT()	
	
	Local cPrefixo   :=  SE2->E2_PREFIXO   
    Local CNFISCAL   :=  SE2->E2_NUM 
	Local DDEMISSAO  :=  SE2->E2_EMISSAO
	Local CA100FOR   :=  SE2->E2_FORNECE
	Local CLOJA      :=  SE2->E2_LOJA
	Local CPARCELA   :=  SE2->E2_PARCELA 
	Local cTipo      :=  SE2->E2_TIPO
	Local _cFilExec  :=  SE2->E2_FILORIG 
	Local dVencto    :=  SE2->E2_VENCTO
	Local cBANCOBX   := 'CX1'
	Local cAGENCIABX := '00001'
	Local cCONTABX   := '0000000001'
	Local nBkpMV_PAR :=  0 
	Local _aAreaSm0  := SM0->(GetArea())

	//Posiciona a SM0
	SM0->(DBSEEK(cEmpAnt + _cFilExec))

	lRet 		:= .F.
	_aCabec     := {}

    Aadd(_aCabec, {"E2_PREFIXO"      , cPrefixo		            , Nil})
	Aadd(_aCabec, {"E2_NUM"          , CNFISCAL                 , Nil})
	Aadd(_aCabec, {"E2_PARCELA"      , CPARCELA			        , Nil})
	Aadd(_aCabec, {"E2_TIPO"         , cTipo		            , Nil})
	Aadd(_aCabec, {"E2_FORNECE"      , CA100FOR       			, Nil})
	Aadd(_aCabec, {"E2_LOJA"         , CLOJA            		, Nil})
		
	Aadd(_aCabec,{"AUTBANCO"        , cBANCOBX   , Nil})
	Aadd(_aCabec,{"AUTAGENCIA"      , cAGENCIABX , Nil})
	Aadd(_aCabec,{"AUTCONTA"        , cCONTABX   , Nil}) 
	
	Aadd(_aCabec,{"AUTHIST"     ,'Baixa Automatica',Nil})//12 //'Baixa Automatica'
	Aadd(_aCabec,{"AUTDESCONT"  ,0                 ,Nil})//13
	Aadd(_aCabec,{"AUTMULTA"    ,0                 ,Nil})//14 
	Aadd(_aCabec,{"AUTJUROS"    ,0                 ,Nil})//15
	Aadd(_aCabec,{"AUTOUTGAS"   ,0                 ,Nil})//16
	Aadd(_aCabec,{"AUTVLRPG"    ,0                 ,Nil})//17
	Aadd(_aCabec,{"AUTVLRME"    ,0                 ,Nil})//18
	Aadd(_aCabec,{"AUTCHEQUE"   ,""                ,Nil})//19
	Aadd(_aCabec,{"AUTTXMOEDA"  ,0                 ,Nil})//20
	Aadd(_aCabec,{"AUTMOTBX"    , "NOR "           ,Nil})
	Aadd(_aCabec,{"AUTDTBAIXA"  , dVencto          ,Nil})
	Aadd(_aCabec,{"AUTDTCREDITO", dVencto          ,Nil})
	
	lMsErroAuto := .F.
	
	//Marco parâmetro para não mostrar Lançamento em tela 
	aPergAux    := {}
	Pergunte("FIN080", .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)
	If MV_PAR01 <> 2
		nBkpMV_PAR  := MV_PAR01
		MV_PAR01 	:= 2
	Endif	
	__SaveParam("FIN080", aPergAux)
	
	
	Begin Transaction
 
		MSExecAuto({|x,y| fina080(x,y)},_aCabec,    3 )
		
		IF lMsErroAuto
			DisarmTransaction()
			Break
		Else
			//SUCESSO
			lRet := .T.
        Endif
	
	End Transaction     
	
	If lRet
	  	cQuery := " UPDATE " + RETSQLNAME("SE5")
		cQuery += " SET E5_BANCO = '"+ cBANCOBX +"', E5_AGENCIA = '"+ cAGENCIABX +"', E5_CONTA = '"+ cCONTABX +"' "
		cQuery += " WHERE E5_PREFIXO = '"  +  cPrefixo        + "' "
		cQuery += "   AND E5_NUMERO  = '"  +  CNFISCAL        + "' "
		cQuery += "   AND E5_DATA    = '"  +  dtos(DDEMISSAO) + "' "
		cQuery += "   AND E5_CLIFOR  = '"  +  CA100FOR        + "' "
		cQuery += "   AND E5_LOJA    = '"  +  CLOJA           + "' "
		cQuery += "   AND D_E_L_E_T_ <> '*' "
		cQuery += "   AND E5_PARCELA = '' "
	  	TcSqlExec(cQuery)
	EndIf
	
	If (Select("QRYSE2") <> 0)
		DbSelectArea("QRYSE2")
		DbCloseArea()
	EndIf
	
	//Volta parâmetro para seu estado original 
	If nBkpMV_PAR > 0 
		MV_PAR01 := nBkpMV_PAR
		__SaveParam("FIN080", aPergAux)
	Endif

	Restarea(_aAreaSm0)	
	Pergunte('SLAAGR10',.F.)


Return 
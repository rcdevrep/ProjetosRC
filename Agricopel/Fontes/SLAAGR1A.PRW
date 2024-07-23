#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------+
// Data : 04/12/2020  Autor: Spiller     |
//---------------------------------------+
// Descrição: Integração de Notas de     |
// Entrada Protheus x EMSYS  			 |
// Baseado em SLAAGR10		 			 |
//---------------------------------------+

User Function SLAAGR1A()

	Local oTmpTable   := Nil
	Local aTam        := {}
	Local aCampBrw    := {}
	Local aRegistros  := {}
	Local cPerg       := "SLAAGR10"

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
	Private cDirTemp  := AllTrim(GetTempPath())	    
	Private _cNome    := "SLAAGR10_"+StrTran(DTOC(Date()),"/","_")+"-"+StrTran(time(),":","")
	Private nHandle   := FCREATE(cDirTemp + _cNome + ".txt")//FCREATE("log_autosystem\"+_cNome+".txt")
	Private nCont     := 0
	Private oXagCon   := XAGConexao():New()
	Private cAliasTRB := ""

	Private lFornece  := .T.
	Private lProduto  := .T.
	Private lItemnf   := .T.
	Private lNFiscal  := .T.
	Private lDupli    := .T.
	Private lFornece1 := .T.
	Private lProduto1 := .T.
	Private lItemnf1  := .T.
	Private lErroProd := .F.
	Private lNFiscal1 := .T.
	Private lDupli1   := .T.
	Private aNotas    := {}
	Private cLog      := ""

	Private aRotina   := { { "Importar" ,"U_AGX720B()" , 0, 1},;
	                       { "Legenda"  ," "           , 0, 3}}

	If cEmpAnt <> '20' .AND. cEmpAnt <> '13'.AND. cEmpAnt <> '17' .AND. cEmpAnt <> '21'.AND. cEmpAnt <> '24'.AND. cEmpAnt <> '25'.AND. cEmpAnt <> '27' .AND. cEmpAnt <> '44' .AND.cEmpAnt <> '51'.AND. cEmpAnt <> '52'.AND. cEmpAnt <> '53'.AND. cEmpAnt <> '57'
		Alert("Atenção! Esta rotina está disponivel somente para as Empresas 13, 17, 20, 21, 24, 25, 27, 44, 51, 52, 53, 57!")
		Return()
	EndIf

	AADD(aRegistros,{cPerg,"01","Data de          ?","mv_ch1","D",08,0,0,"G","","mv_par01" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Data até         ?","mv_ch2","D",08,0,0,"G","","mv_par02" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Num. NF          ?","mv_ch3","C",09,0,0,"G","","mv_par03" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Série NF         ?","mv_ch4","C",03,0,0,"G","","mv_par04" ,"","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Filial           ?","mv_ch5","C",02,0,0,"G","","mv_par05" ,"","","","","","","","","","","","","","","SM0"})
	AADD(aRegistros,{cPerg,"06","Fornecedor       ?","mv_ch6","C",09,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SA2"})
	AADD(aRegistros,{cPerg,"07","Importar.	      ?","mv_ch7","N",1,0,0,"C","","mv_par07","Não Importados","","","Todos","","","","","","","","","","",""})	
	
	U_CriaPer(cPerg,aRegistros)

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	oTmpTable := CriarTRB()
	cAliasTRB := oTmpTable:GetAlias()

	Processa({|| DadosTrb()}, "Buscando Info. no EMSYS,Aguarde...")

	AADD(aCampBrw,{"Filial", "FILIAL", "C",2,0, "" } )
	AADD(aCampBrw,{"Emissão", "EMISSAO", "D",8,0, "" } )

	aTam:=TamSX3("F1_DOC")
	AADD(aCampBrw,{"Nota Fiscal", "DOCUMENTO","C",aTam[1],aTam[2], "" } )

	aTam:=TamSX3("F1_SERIE")
	AADD(aCampBrw,{"Serie", "SERIE","C",aTam[1],aTam[2], "" } )

	AADD(aCampBrw,{"Fornecedor (Grid)", "FORNECEDOR","C",15,0, "" } )

	aTam:=TamSX3("F1_TIPO")
	AADD(aCampBrw,{"Tipo", "TIPO","C",aTam[1],aTam[2], "" } )

	aTam:=TamSX3("A2_NOME")
	AADD(aCampBrw,{"Nome Fornecedor", "NOMEFOR","C",aTam[1],aTam[2], "" } )

	AADD(aCampBrw,{"CNPJ/CPF", "CGC","C",15,0, "" } )

	aTam:=TamSX3("F1_VALMERC")
	AADD(aCampBrw,{"Total", "TOTAL","C",aTam[1],aTam[2], "@E 999,999,999.99" } )

	AADD(aCampBrw,{"Fornecedor (Protheus)", "CDFORNEC","C",15,0, "" } )
	AADD(aCampBrw,{"Loja (Protheus)", "FORNECLJ","C",15,0, "" } )

	aTam:=TamSX3("F1_TIPO")
	AADD(aCampBrw,{"Finalidade", "FINALID","C",aTam[1],aTam[2], "" } )

	dbSelectArea(cAliasTRB)
	dbSetOrder(1)
	mBrowse(6,1,22,75,cAliasTRB,aCampBrw)

	(cAliasTRB)->(DbCloseArea())
	oTmpTable:Delete()
	FreeObj(oTmpTable)

Return()

Static Function CriarTRB()

	Local aCampos   := {}
	Local aTam      := {}
	Local oTmpTable := Nil

	aTam:=TamSX3("F1_FILIAL")
	AADD(aCampos,{"FILIAL"         ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("A2_NOME")
	AADD(aCampos,{"NOMEFOR"        ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_DOC")
	AADD(aCampos,{"DOCUMENTO"      ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_SERIE")
	AADD(aCampos,{"SERIE"          ,"C",aTam[1],aTam[2] } )

	AADD(aCampos,{"FORNECEDOR"     ,"C", 15,0 } )
	AADD(aCampos,{"EMISSAO"        ,"D",8      ,      0 } )

	aTam:=TamSX3("F1_TIPO")
	AADD(aCampos,{"TIPO"           ,"C",aTam[1],aTam[2] } )

	AADD(aCampos,{"CGC"            ,"C",20     ,0       } )

	aTam:=TamSX3("F1_VALMERC")
	AADD(aCampos,{"TOTAL"          ,"N",aTam[1],aTam[2] } )

	AADD(aCampos,{"CDFORNEC"     ,"C", 15,0 } )
	AADD(aCampos,{"FORNECLJ"     ,"C", 15,0 } )

	aTam:=TamSX3("F1_TIPO")
	AADD(aCampos,{"FINALID", "C",aTam[1],aTam[2], "" } )

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aCampos)
	oTmpTable:AddIndex("1", {"DOCUMENTO"})
	oTmpTable:Create()

Return(oTmpTable)

Static Function DadosTrb()

	Local cQuery        := ""
	Private _cXFilial   := ""
	Private lNaoExiste  := .T.
	Private cA2PJ       := ""
	Private cLoja       := ""
	Private cFornecedor := ""
	Private lValCGC     := .F.

	If nHandle = -1
		// Conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	Else
		FWrite(nHandle, Time() + CRLF)
	Endif

	If (!oXagCon:ConecEMS())
		MsgAlert("Não foi possivel conectar ao EMSYS ...")
		FWrite(nHandle, "SLAARG10 - Não foi possivel conectar ao EMSYS." + CRLF)
		Return
	Else
		FWrite(nHandle, "SLAAGR10 - Conexão com o servidor estabelecida." + CRLF)

		oXagCon:ConecPRT()

		DbSelectArea("SM0")
		DbGotop()
		While !Eof()
			If SM0->M0_CODIGO == cEmpAnt
				If Alltrim(MV_PAR05) == Alltrim(SM0->M0_CODFIL)
					cFilAte:= Transform(SM0->M0_CGC, "@R 99999999999999")//Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")
				EndIf
			EndIf
			DbSelectArea("SM0")
			DbSkip()
		EndDo
		DbSelectArea("SM0")
		DbGotop()
		While !Eof()
			If SM0->M0_CODIGO == cEmpAnt
				If cFilAnt == Alltrim(SM0->M0_CODFIL)
					cFilDe:= Transform(SM0->M0_CGC, "@R 99999999999999")//Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")
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

		oXagCon:ConecEMS()

		cTRF1:= "select tnfe.num_nota  as F1_DOC,"+chr(13)
		cTRF1+= "cast(tnfe.num_serie as varchar(3))  as F1_SERIE,"+chr(13)
		cTRF1+= "cast(tnfe.seq_nota as varchar(20)) as F1_MLID,"+chr(13)
		cTRF1+= "tnfe.dta_emissao as F1_EMISSAO,"+chr(13)
		cTRF1+= "tnfe.dta_entrada  as F1_DTDIGIT ,"+chr(13)
		cTRF1+= "tnfe.val_frete_cif  as F1_FRETE,"+chr(13)
		cTRF1+= "tnfe.val_despesa_acessoria as F1_DESPESA,"+chr(13)
		cTRF1+= "tnfe.val_base_icms as F1_BASEICM,"+chr(13)
		cTRF1+= "tnfe.val_icms as F1_VALICM,"+chr(13)
		cTRF1+= "case when tnfe.val_total_nota > 0 then tnfe.val_total_nota else tnfe.val_total_servico end as F1_VALMERC,"+chr(13)
		cTRF1+= "(select sum(tin.val_desconto) + sum(tin.val_desconto_rateio)"+chr(13)
		cTRF1+= "        from tab_item_nfe tin"+chr(13)
		cTRF1+= "        where tin.seq_nota =  tnfe.seq_nota) as F1_DESCONT,"+chr(13)
		cTRF1+= "tnfe.qtd_peso_liquido as F1_PESOL,"+chr(13)
		cTRF1+= "case when tnfe.cod_mod_frete is null then 'C' else 'F' end as F1_TPFRETE, "+chr(13)
		cTRF1+= "tnfe.val_seguro as valor_seguro,"+chr(13)
		cTRF1+= "tnfe.seq_nota as F1_GRID,"+chr(13)
		cTRF1+= "tnfe.ind_status as F1_TIPO,"+chr(13)
		cTRF1+= "tp.cod_pessoa as destinatario,"+chr(13)
		cTRF1+= "te.cod_empresa as empresa,"+chr(13)
		cTRF1+= "cast(tp.num_cnpj_cpf as varchar(20)) as F1_CGC,"+chr(13)
		cTRF1+= "cast(te.num_cnpj as varchar(20)) as DESTINO,"+chr(13)
		cTRF1+= " tmdf.cod_modelo_doc_anexo_7  as MODELO,"+chr(13)
		cTRF1+= "cast(tp.nom_pessoa as varchar(50)) as F1_DESC,"+chr(13)
		cTRF1+= "tnfe.val_base_icms_substituicao as F1_BRICMS,"+chr(13)
		cTRF1+= "tnfe.val_icms_substituicao as F1_ICMSRET,"+chr(13)
		cTRF1+= "cast(replace(tno.num_cfop,'.','') as varchar(20)) as F1_CFO,"+chr(13)
		cTRF1+= "COALESCE(tnfe.num_chave_nfe,'') as F1_CHVNFE,"+chr(13)
		cTRF1+= "tnfe.cod_pessoa_fornecedor  as F1_FORNECE,"+chr(13)
		cTRF1+= "tnfe.val_base_iss as base_iss,"+chr(13)
		cTRF1+= "case when tnfe.val_iss = 0 then (select coalesce(sum(tno.val_retencao),0)  "+chr(13)      
        cTRF1+= "     from tab_nfe_retencao tno        "+chr(13)
        cTRF1+= "     where tno.ind_tipo_imposto = 'ISS' "    +chr(13)   
        cTRF1+= "     and tno.seq_nota  = tnfe.seq_nota) else tnfe.val_iss end as F1_ISS,"+chr(13)
		//cTRF1+= "tnfe.val_iss as F1_ISS,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'IR'"+chr(13)
		cTRF1+= "       and tno.seq_nota  = tnfe.seq_nota)  as F1_BASEIR,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'IR'"+chr(13)
		cTRF1+= "        and tno.seq_nota  = tnfe.seq_nota) as F1_VALIRF,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto IN ('CSLL','PCC')"+chr(13)
		cTRF1+= "        and tno.seq_nota  = tnfe.seq_nota) as F1_BASCSLL,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "       where tno.ind_tipo_imposto IN ('CSLL','PCC')"+chr(13)
		cTRF1+= "       and tno.seq_nota  = tnfe.seq_nota) as F1_VALCSLL,"+chr(13)
		cTRF1+= " (select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'INSS'"+chr(13)
		cTRF1+= "        and tno.seq_nota  = tnfe.seq_nota) as F1_BASEINS,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "       where tno.ind_tipo_imposto = 'INSS'"+chr(13)
		cTRF1+= "       and tno.seq_nota  = tnfe.seq_nota) as F1_INSS,"+chr(13)
		cTRF1+= "    coalesce(tnfe.val_ipi,0) as F1_VALIPI,"+chr(13)
		cTRF1+= "    coalesce(tnfe.val_pis_recuperar,0) as F1_VALPIS,"+chr(13)
		cTRF1+= "   coalesce(tnfe.val_cofins_recuperar,0) as F1_VALCOFI,"+chr(13)
		cTRF1+= "    tnfe.ind_finalidade_nota as F1_TIPN,"+chr(13)
		cTRF1+= "    tnfe.val_total_nota as F1_VALBRUT" +chr(13)
		cTRF1+= " from tab_nota_fiscal_entrada tnfe "+chr(13)
		cTRF1+= " inner join tab_pessoa tp on (tnfe.cod_pessoa_fornecedor = tp.cod_pessoa)"+chr(13)
		cTRF1+= " inner join tab_empresa te on (te.cod_empresa = tnfe.cod_empresa)"+chr(13)
		cTRF1+= " inner join tab_modelo_documento_fiscal tmdf on (tmdf.cod_modelo_documento = tnfe.cod_modelo_documento)"+chr(13)
		cTRF1+= " inner join tab_natureza_operacao tno on (tno.cod_natureza_operacao = tnfe.cod_natureza_operacao)"+chr(13)
		//cTRF1+= " left join tab_nfe_retencao tnr on (tnr.seq_nota = tnfe.seq_nota)"
		cTRF1+= " where tnfe.dta_entrada between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"' and tnfe.dta_entrada >= '20201201' "+chr(13)
		cTRF1+= " and tnfe.ind_cancelado not in ('C') "   +chr(13)                                                                              
		If !Empty(Alltrim(MV_PAR03))
			cTRF1+= " and (tnfe.num_nota = '"+Alltrim(cValToChar(Val(MV_PAR03)))+"') "+chr(13)
		EndIf
		If !Empty(Alltrim(MV_PAR04))
			cTRF1+= " and (tnfe.num_serie = '"+Alltrim(MV_PAR04)+"' )"+chr(13)
		EndIf
		If !Empty(Alltrim(cFilAte))
			cTRF1+= " and (te.num_cnpj = '"+cFilAte+"'  )"+chr(13)
		Else                             
		cTRF1+= " and (te.num_cnpj = '"+cFilDe+"') " +chr(13)
		EndIf
		If !Empty(Alltrim(MV_PAR06))
			cTRF1+= " and (tp.num_cnpj_cpf = '"+cPessoa+"') "+chr(13)
		EndIf
		cTRF1+= " union all "+chr(13)
		cTRF1+= "select tc.num_conhecimento as F1_DOC,"+chr(13)
		cTRF1+= "tc.num_serie as F1_SERIE,"+chr(13)
		cTRF1+= "cast(tc.seq_conhecimento as varchar(20)) as F1_MLID, "+chr(13)
		cTRF1+= "tc.dta_emissao as F1_DTDIGIT,"+chr(13)
		cTRF1+= "tc.dta_entrada as F1_EMISSAO,"+chr(13)
		cTRF1+= "0 as F1_FRETE,"+chr(13)
		cTRF1+= "tc.val_despesa_acessoria as F1_DESPESA,"+chr(13)
		cTRF1+= "tc.val_base_icms as F1_BASEICM,"+chr(13)
		cTRF1+= "tc.val_icms as F1_VALICM,"+chr(13)
		cTRF1+= "tc.val_total_frete as F1_VALMERC,"+chr(13)
		cTRF1+= "0 as F1_DESCONT,"+chr(13)
		cTRF1+= "0 as F1_PESOL,"+chr(13)
		cTRF1+= "case when tc.ind_tipofrete = '1' then 'C' else 'F' end as F1_TPFRETE,"+chr(13)
		cTRF1+= "tc.val_seguro as valor_seguro,"+chr(13)
		cTRF1+= "tc.seq_conhecimento as F1_GRID,"+chr(13)
		cTRF1+= "tc.ind_nat_frete as F1_TIPO,"+chr(13)
		cTRF1+= "tp.cod_pessoa as destinatario,"+chr(13)
		cTRF1+= "tc.cod_empresa as empresa,"+chr(13)
		cTRF1+= "tp.num_cnpj_cpf as F1_CGC,"+chr(13)
		cTRF1+= "te.num_cnpj as DESTINO,"+chr(13)
		cTRF1+= "tmdf.cod_modelo_doc_anexo_7  as MODELO,"+chr(13)
		cTRF1+= "tp.nom_pessoa as F1_DESC,"+chr(13)
		cTRF1+= "tc.val_base_st as F1_BRICMS,"+chr(13)
		cTRF1+= "tc.val_st as F1_ICMSRET,"+chr(13)
		cTRF1+= "tno.num_cfop as F1_CFO,"+chr(13)
		cTRF1+= "coalesce(tc.num_chave_nfe,'') as F1_CHVNFE,"+chr(13)
		cTRF1+= "tc.cod_pessoa_transportadora  as F1_FORNECE,"+chr(13)
		cTRF1+= "0 as base_iss,"+chr(13)
		cTRF1+= "0 as F1_ISS,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'IR'"+chr(13)
		cTRF1+= "        and tno.seq_conhecimento  = tc.seq_conhecimento)  as F1_BASEIR,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'IR'"+chr(13)
		cTRF1+= "       and tno.seq_conhecimento  = tc.seq_conhecimento) as F1_VALIRF,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto IN ('CSLL','PCC')"+chr(13)
		cTRF1+= "        and tno.seq_conhecimento  = tc.seq_conhecimento) as F1_BASCSLL,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto IN ('CSLL','PCC')"+chr(13)
		cTRF1+= "        and tno.seq_conhecimento  = tc.seq_conhecimento) as F1_VALCSLL,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'INSS'"+chr(13)
		cTRF1+= "        and tno.seq_conhecimento  = tc.seq_conhecimento) as F1_BASEINS,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'INSS'"+chr(13)
		cTRF1+= "        and tno.seq_conhecimento  = tc.seq_conhecimento) as F1_INSS,"+chr(13)
		cTRF1+= "0 as F1_VALIPI,"+chr(13)
		//cTRF1+= "0 as F1_VALIMP6,"
		cTRF1+= "tc.val_pis_recuperar as F1_VALPIS,"+chr(13)
		//cTRF1+= "0 as F1_VALIMP5,"
		cTRF1+= "tc.val_cofins_recuperar as F1_VALCOFI,"+chr(13)
		cTRF1+= "tc.ind_finalidade as F1_TIPN,"+chr(13)
		cTRF1+= "tc.val_total_frete as F1_VALBRUT"+chr(13)
		cTRF1+= " from tab_conhecimento tc "+chr(13)
		cTRF1+= " inner join tab_pessoa tp on (tp.cod_pessoa = tc.cod_pessoa_transportadora)"+chr(13)
		cTRF1+= " inner join tab_empresa te on (te.cod_empresa = tc.cod_empresa)"+chr(13)
		cTRF1+= " inner join tab_modelo_documento_fiscal tmdf on (tmdf.cod_modelo_documento = tc.cod_modelo_documento)"+chr(13)
		cTRF1+= " inner join tab_natureza_operacao tno on (tno.cod_natureza_operacao = tc.cod_natureza_operacao)"+chr(13)
		cTRF1+= " where tc.dta_entrada  between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"' and tc.dta_entrada  >= '20201201' "+chr(13)
		If !Empty(Alltrim(MV_PAR03))
			cTRF1+= "and (tc.num_conhecimento = '"+Alltrim(cValToChar(Val(MV_PAR03)))+"') "+chr(13)
		EndIf
		If !Empty(Alltrim(MV_PAR04))
			cTRF1+= "and tc.num_serie = '"+Alltrim(MV_PAR04)+"' "+chr(13)
		EndIf
		If !Empty(Alltrim(cFilAte))
			cTRF1+= "and  (te.num_cnpj = '"+cFilAte+"' )"+chr(13)
		Else                             
			cTRF1+= "and (te.num_cnpj = '"+cFilDe+"' )"+chr(13)
		EndIf
		If !Empty(Alltrim(MV_PAR06))
			cTRF1+= "and tp.num_cnpj_cpf  = '"+cPessoa+"' " +chr(13)
		EndIf
		cTRF1+= "order by F1_DTDIGIT"+chr(13)

		conout(cTRF1)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRF1 ), "QRYTKE", .F., .T.)

		oXagCon:ConecPRT()
		DbSelectArea("QRYTKE")
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
					_cXFilial := Alltrim(SM0->M0_CODFIL)
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
					cQuery += "     AND F1_DOC     = '" + PADL(alltrim(QRYTKE->F1_DOC),9,'0')/*cValToChar(Strzero(QRYTKE->F1_DOC,9))*/  + "' "
					cQuery += "     AND (F1_SERIE   = '" + Alltrim(QRYTKE->F1_SERIE) + "' OR  F1_SERIE   = '" + Alltrim(StrTran( QRYTKE->F1_SERIE, "0", "" )) + "' )"
					cQuery += "     AND D_E_L_E_T_ = ''  "
					conout(cQuery)
					If Select("QRY_SF2") <> 0
						dbSelectArea("QRY_SF2")
						dbCloseArea()
					Endif

					TCQuery cQuery NEW ALIAS "QRY_SF2"

					DbSelectArea("QRY_SF2")
					While ! EOF()
						lNaoExiste := .F.
						DbSelectArea("QRY_SF2")
						DbSkip()
					EndDo
					If lNaoExiste //.or. MV_PAR07 == 2  //TODOS RETIRADO PARA EVITAR DUPLICIDADE
						If _cXFilial <> ""
							nCont ++
							RecLock(cAliasTRB,.T.)
							(cAliasTRB)->FILIAL       := _cXFilial
							(cAliasTRB)->DOCUMENTO    := PADL(alltrim(QRYTKE->F1_DOC),9,'0')//cValToChar(Strzero(QRYTKE->F1_DOC,9))
							(cAliasTRB)->NOMEFOR      := QRYTKE->F1_DESC
							(cAliasTRB)->SERIE        := Alltrim(QRYTKE->F1_SERIE)
							(cAliasTRB)->FORNECEDOR   := cValToChar((QRYTKE->F1_FORNECE))
							(cAliasTRB)->EMISSAO      := QRYTKE->F1_EMISSAO
							(cAliasTRB)->TIPO         := QRYTKE->F1_TIPO
							(cAliasTRB)->CGC		  := QRYTKE->F1_CGC
							(cAliasTRB)->TOTAL        := QRYTKE->F1_VALMERC
							(cAliasTRB)->CDFORNEC     := Alltrim(cFornecedor)
							(cAliasTRB)->FORNECLJ     := Alltrim(cLoja)
							(cAliasTRB)->FINALID      := Alltrim(QRYTKE->F1_TIPN)
							MsUnlock()

							AADD( aNotas, { QRYTKE->F1_DOC ,QRYTKE->F1_SERIE ,QRYTKE->F1_CGC })	
						EndIf
					EndIf
					lNaoExiste := .T.
				EndIf
				cA2PJ       := ""
				cFornecedor := ""
				cLoja       := ""
			EndIf
			DbSelectArea("QRYTKE")
			DbSkip()
		EndDo
	EndIf

	oXagCon:DescEMS()

Return()

//--------------------------------------------+
//                                            |
//--------------------------------------------+
User Function AGX720B()

	If !msgyesno("Deseja continuar a importação?")
		return()
	else
		Processa({|| Importa()}, "Importando Notas! Aguarde...")
	EndIF

Return()

Static Function Importa()

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

	If (!oXagCon:ConecEMS())
		// Conout("SLAAGR10 - *** Não foi possível conectar ao AutoSystem...")
		RETURN
	Else
		DadosCapa()

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
					_cXFilial:= Alltrim(SM0->M0_CODFIL)
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

					oXagCon:ConecEMS()
					DadosForn() // --------------------- CARREGA INFORMAÇÃO DOS FORNECEDORES

					if TRF1->F1_TIPN <> 'D'
						GravForn() // --------------------- GRAVA FORNECEDORES
					else
						GravClie() // --------------------- GRAVA CLIENTES
					endif

					oXagCon:ConecEMS()
					
					If lFornece
						If TRF1->MODELO == 57 //CTE
					 		lItemNf := .T.
							lNFiscal  := .T.

							//Grava dados Da SD1
							oXagCon:ConecPRT()
					 		GravaCte(cCGC)
							GravCapa(cCGC)

							//Busca Dados da Duplicata
							oXagCon:ConecEMS()
							DadosDuCTE()

							//Grava dados duplicata 
							oXagCon:ConecPRT()
							TRE2->(DbGoTop())
							While TRE2->(!EOF())
								If (Alltrim(cValtoChar(TRF1->F1_DOC)) == Alltrim(TRE2->E2_NUM))
									GravDupl(cCGC) // ------------------------- GRAVA A DUPLICATA
									nParcela ++
								EndIf
								DbSelectArea("TRE2")
								DbSkip()
							EndDo

						Else //Nota fiscal
							DadosItem() // --------------------- CARREGA INFORMAÇÕES DOS ITENS
							DbSelectArea("TRD1")
							TRD1->(DbGoTop())
							While TRD1->(!EOF())
								cProduto:= TRD1->D1_PRODUTO
								oXagCon:ConecEMS()
								DadosProd()   // --------------------- CARREGA INFORMAÇÕES DOS PRODUTOS
								DbSelectArea("TRB1")
								DbGoTop()
								While TRB1->(!EOF())
									If cValToChar(cProduto) == Alltrim(STR(TRB1->B1_GRID))
										oXagCon:ConecPRT()
										GravProd() // -------------------------- GRAVA PRODUTOS
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
								TRB1->(DbCloseArea())
								If lProduto == .F.
									Exit
								EndIf
								DbSelectArea("TRD1")
								TRD1->(DbSkip())
							EndDo

							DbSelectArea("TRD1")
							TRD1->(DbGoTop())
							Begin Transaction
							While TRD1->(!EOF())
								If lProduto
									If TRF1->F1_DOC == TRD1->D1_DOC
										GravItem(cCGC) // ------------------------------- GRAVA OS ITENS DA NF
										nItem ++
									EndIf
								Else
									Fwrite(nHandle, "ITENS DA NOTA FISCAL| ERRO  | NOTA FISCAL "+cValToChar(TRD1->D1_DOC)+"  ITEM "+cValToChar(cProduto)+"| NAO CADASTRADO NO PROTHEUS" + CRLF)
									lItemnf := .F.
									lItemnf1:= .F.
									Exit
								EndIf
								DbSelectArea("TRD1")
								TRD1->(DbSkip())
							EndDo

							//Caso tenha dado algum erro nos itens desfaz transação
							If !lItemnf
								DisarmTransaction()
							Endif
							MsUnlockAll() 
							End transaction

							cValIss  := 0
							cValIrr  := 0
							cValInss := 0
							cValPis  := 0
							cValCof  := 0
							cValCsl  := 0
							TRD1->(DbCloseArea())
												
							If lItemnf
								oXagCon:ConecPRT()
								GravCapa(cCGC)
							Else
								Fwrite(nHandle, "CAPA DA NOTA FISCAL | AVISO  | NOTA FISCAL "+cValToChar(TRF1->F1_DOC)+"|NAO IMPORTADA" + CRLF)
								lNFiscal:= .F.
								//lNFiscal1:= .F.
							EndIf

							If lNFiscal
								if cStatus == "A"
									oXagCon:ConecEMS()
									DadosDupl() // ------------------------- CARREGA INFORMAÇÕES DAS DUPLICATAS
									DbSelectArea("TRE2")
									DbGoTop()
									//Count To nQtdeReg
									nQtdeReg := Contar("TRE2","!Eof()") //RecCount("TRE2")
									DbGoTop()
									While TRE2->(!EOF())
										If (Alltrim(cValtoChar(TRF1->F1_DOC)) == Alltrim(TRE2->E2_NUM))
											GravDupl(cCGC) // ------------------------- GRAVA A DUPLICATA
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
							EndIf

							If (Select("TRE2") > 0)
								TRE2->(DbCloseArea())
							EndIf

						Endif 
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

	If lFornece1 <> .T. .Or. lProduto1 <> .T. .Or. lItemnf1  <> .T. .Or. lNFiscal1 <> .T. .Or. lDupli1 <> .T. .OR. lErroProd
		Fwrite(nHandle, "ERRO| CORRIGIR OS ERROS E IMPORTAR NOVAMENTE." + CRLF)
		FClose(nHandle)
			
		//Abre Bloco de Notas
	   	shellExecute( "Open", "C:\Windows\System32\notepad.exe", _cNome+".txt", cDirTemp, 1 )

		MsgAlert("***    Existem erros no arquivo favor verificar o log.txt     ***")
	
	Else
		MsgAlert("***    Importação Realizada com Sucesso!!!")
		Fwrite(nHandle, "SLAAGR1A - IMPORTACAO REALIZADA COM SUCESSO." + CRLF)
		FClose(nHandle)
	EndIf

	lFornece1 := .T.
	lProduto1 := .T.
	lItemnf1  := .T.
	lNFiscal1 := .T.
	lDupli1   := .T.

	CloseBrowse()

	oXagCon:DescEMS()

Return ()

//------------------------------------------+
// BUSCA INFORMAÇÃO DA CAPA DA NOTA         |
//------------------------------------------+
Static Function DadosCapa()

	Local cTRF1 := ""
	Local _n    := 0 

		cTRF1:= "select tnfe.num_nota  as F1_DOC,"+chr(13)
		cTRF1+= "cast(tnfe.num_serie as varchar(3))  as F1_SERIE,"+chr(13)
		cTRF1+= "cast(tnfe.seq_nota as varchar(20)) as F1_MLID,"+chr(13)
		cTRF1+= "tnfe.dta_emissao as F1_EMISSAO,"+chr(13)
		cTRF1+= "tnfe.dta_entrada  as F1_DTDIGIT ,"+chr(13)
		cTRF1+= "tnfe.val_frete_cif  as F1_FRETE,"+chr(13)
		cTRF1+= "tnfe.val_despesa_acessoria as F1_DESPESA,"+chr(13)
		cTRF1+= "tnfe.val_base_icms as F1_BASEICM,"+chr(13)
		cTRF1+= "tnfe.val_icms as F1_VALICM,"+chr(13)
		cTRF1+= "case when tnfe.val_total_nota > 0 then tnfe.val_total_nota else tnfe.val_total_servico end as F1_VALMERC,"+chr(13)
		cTRF1+= "(select sum(tin.val_desconto) + sum(tin.val_desconto_rateio)"+chr(13)
		cTRF1+= "        from tab_item_nfe tin"+chr(13)
		cTRF1+= "        where tin.seq_nota =  tnfe.seq_nota) as F1_DESCONT,"+chr(13)
		cTRF1+= "tnfe.qtd_peso_liquido as F1_PESOL,"+chr(13)
		cTRF1+= "case when tnfe.cod_mod_frete is null then 'C' else 'F' end as F1_TPFRETE, "+chr(13)
		cTRF1+= "tnfe.val_seguro as valor_seguro,"+chr(13)
		cTRF1+= "tnfe.seq_nota as F1_GRID,"+chr(13)
		cTRF1+= "tnfe.ind_status as F1_TIPO,"+chr(13)
		cTRF1+= "tp.cod_pessoa as destinatario,"+chr(13)
		cTRF1+= "te.cod_empresa as empresa,"+chr(13)
		cTRF1+= "cast(tp.num_cnpj_cpf as varchar(20)) as F1_CGC,"+chr(13)
		cTRF1+= "cast(te.num_cnpj as varchar(20)) as DESTINO,"+chr(13)
		cTRF1+= "tmdf.cod_modelo_doc_anexo_7  as MODELO,"+chr(13)
		cTRF1+= "cast(tp.nom_pessoa as varchar(50)) as F1_DESC,"+chr(13)
		cTRF1+= "tnfe.val_base_icms_substituicao as F1_BRICMS,"+chr(13)
		cTRF1+= "tnfe.val_icms_substituicao as F1_ICMSRET,"+chr(13)
		cTRF1+= "cast(replace(tno.num_cfop,'.','') as varchar(20)) as F1_CFO,"+chr(13)
		cTRF1+= "COALESCE(tnfe.num_chave_nfe,'') as F1_CHVNFE,"+chr(13)
		cTRF1+= "tnfe.cod_pessoa_fornecedor  as F1_FORNECE,"+chr(13)
		cTRF1+= "tnfe.val_base_iss as base_iss,"+chr(13)
		cTRF1+= "case when tnfe.val_iss = 0 then (select coalesce(sum(tno.val_retencao),0)  " +chr(13)     
        cTRF1+= "     from tab_nfe_retencao tno        "+chr(13)
        cTRF1+= "     where tno.ind_tipo_imposto = 'ISS' "     +chr(13)  
        cTRF1+= "     and tno.seq_nota  = tnfe.seq_nota) else tnfe.val_iss end as F1_ISS,"+chr(13)
		//cTRF1+= "tnfe.val_iss as F1_ISS,"
		cTRF1+= "(select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'IR'"+chr(13)
		cTRF1+= "       and tno.seq_nota  = tnfe.seq_nota)  as F1_BASEIR,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'IR'"+chr(13)
		cTRF1+= "        and tno.seq_nota  = tnfe.seq_nota) as F1_VALIRF,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto IN ('CSLL','PCC')"+chr(13)
		cTRF1+= "        and tno.seq_nota  = tnfe.seq_nota) as F1_BASCSLL,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "       where tno.ind_tipo_imposto IN ('CSLL','PCC')"+chr(13)
		cTRF1+= "       and tno.seq_nota  = tnfe.seq_nota) as F1_VALCSLL,"+chr(13)
		cTRF1+= " (select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'INSS'"+chr(13)
		cTRF1+= "        and tno.seq_nota  = tnfe.seq_nota) as F1_BASEINS,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_nfe_retencao tno"+chr(13)
		cTRF1+= "       where tno.ind_tipo_imposto = 'INSS'"+chr(13)
		cTRF1+= "       and tno.seq_nota  = tnfe.seq_nota) as F1_INSS,"+chr(13)
		cTRF1+= "    coalesce(tnfe.val_ipi,0) as F1_VALIPI,"+chr(13)
		cTRF1+= "  tnfe.val_pis_recuperar as F1_VALIMP6, "+chr(13)
        cTRF1+= "         			 (select coalesce(sum(tnr.val_retencao),0)          "+chr(13)
        cTRF1+= " 							from tab_nfe_retencao tnr     "+chr(13)
        cTRF1+= "         					where tnr.ind_tipo_imposto = 'PIS'        " +chr(13)
        cTRF1+= "        					and tnr.seq_nota  = tnfe.seq_nota) as    F1_VALPIS, " +chr(13) 
        cTRF1+= " tnfe.val_cofins_recuperar  as F1_VALIMP5, "+chr(13)
        cTRF1+= "         			 (select coalesce(sum(tnr.val_retencao),0)    "    +chr(13)  
        cTRF1+= " 							from tab_nfe_retencao tnr     "+chr(13)
        cTRF1+= "         					where tnr.ind_tipo_imposto = 'COFINS'  "   +chr(13)    
        cTRF1+= "         					and tnr.seq_nota  = tnfe.seq_nota)  as    F1_VALCOFI,"+chr(13)
		cTRF1+= "    tnfe.ind_finalidade_nota as F1_TIPN,"+chr(13)
		cTRF1+= "    tnfe.val_total_nota as F1_VALBRUT" +chr(13)
		cTRF1+= " from tab_nota_fiscal_entrada tnfe "+chr(13)
		cTRF1+= " inner join tab_pessoa tp on (tnfe.cod_pessoa_fornecedor = tp.cod_pessoa)"+chr(13)
		cTRF1+= " inner join tab_empresa te on (te.cod_empresa = tnfe.cod_empresa)"+chr(13)
		cTRF1+= " inner join tab_modelo_documento_fiscal tmdf on (tmdf.cod_modelo_documento = tnfe.cod_modelo_documento)"+chr(13)
		cTRF1+= " inner join tab_natureza_operacao tno on (tno.cod_natureza_operacao = tnfe.cod_natureza_operacao)"+chr(13)
		//cTRF1+= " left join tab_nfe_retencao tnr on (tnr.seq_nota = tnfe.seq_nota)"
		cTRF1+= " where tnfe.dta_entrada between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"' and tnfe.dta_entrada  >= '20201201' "+chr(13)
		cTRF1+= " and tnfe.ind_cancelado not in ('C')                   " +chr(13)                                                              
		If !Empty(Alltrim(MV_PAR03))
			cTRF1+= "and (tnfe.num_nota = '"+Alltrim(cValToChar(Val(MV_PAR03)))+"') "+chr(13)
		EndIf
		If !Empty(Alltrim(MV_PAR04))
			cTRF1+= "and (tnfe.num_serie = '"+Alltrim(MV_PAR04)+"' )"+chr(13)
		EndIf
		If !Empty(Alltrim(cFilAte))
			cTRF1+= "and (te.num_cnpj = '"+cFilAte+"'  )"+chr(13)
		Else                             
		cTRF1+= "and (te.num_cnpj = '"+cFilDe+"') " +chr(13)
		EndIf
		If !Empty(Alltrim(MV_PAR06))
			cTRF1+= "and (tp.num_cnpj_cpf = '"+cPessoa+"') "+chr(13)
		EndIf
		
		If len(aNotas) > 0 //MV_PAR07 == 1//Somente não importados
		
			cTRF1+= " and cast(tnfe.num_nota  as varchar(9)) || cast(tnfe.num_serie as varchar(3)) ||  cast(tp.num_cnpj_cpf as varchar(20)) IN('"
			For _n := 1 to len(aNotas)
				cTRF1 +=   alltrim(aNotas[_n][1]) + Alltrim(Alltrim(anotas[_n][2] ))+Alltrim(Alltrim(anotas[_n][3] ))
				cTRF1 += iif(_n <> len(aNotas), "','","' )") 
			Next _n 
	
		Endif
		
		cTRF1+= " union all "+chr(13)
		cTRF1+= "select tc.num_conhecimento as F1_DOC,"+chr(13)
		cTRF1+= "tc.num_serie as F1_SERIE,"+chr(13)
		cTRF1+= "cast(tc.seq_conhecimento as varchar(20)) as F1_MLID, "+chr(13)
		cTRF1+= "tc.dta_entrada as F1_DTDIGIT,"+chr(13)
		cTRF1+= "tc.dta_emissao as F1_EMISSAO,"+chr(13)
		cTRF1+= "0 as F1_FRETE,"+chr(13)
		cTRF1+= "tc.val_despesa_acessoria as F1_DESPESA,"+chr(13)
		cTRF1+= "tc.val_base_icms as F1_BASEICM,"+chr(13)
		cTRF1+= "tc.val_icms as F1_VALICM,"+chr(13)
		cTRF1+= "tc.val_total_frete as F1_VALMERC,"+chr(13)
		cTRF1+= "0 as F1_DESCONT,"+chr(13)
		cTRF1+= "0 as F1_PESOL,"+chr(13)
		cTRF1+= "case when tc.ind_tipofrete = '1' then 'C' else 'F' end as F1_TPFRETE,"+chr(13)
		cTRF1+= "tc.val_seguro as valor_seguro,"+chr(13)
		cTRF1+= "tc.seq_conhecimento as F1_GRID,"+chr(13)
		cTRF1+= "tc.ind_nat_frete as F1_TIPO,"+chr(13)
		cTRF1+= "tp.cod_pessoa as destinatario,"+chr(13)
		cTRF1+= "tc.cod_empresa as empresa,"+chr(13)
		cTRF1+= "tp.num_cnpj_cpf as F1_CGC,"+chr(13)
		cTRF1+= "te.num_cnpj as DESTINO,"+chr(13)
		cTRF1+= "tmdf.cod_modelo_doc_anexo_7  as MODELO,"+chr(13)
		cTRF1+= "tp.nom_pessoa as F1_DESC,"+chr(13)
		cTRF1+= "tc.val_base_st as F1_BRICMS,"+chr(13)
		cTRF1+= "tc.val_st as F1_ICMSRET,"+chr(13)
		cTRF1+= "tno.num_cfop as F1_CFO,"+chr(13)
		cTRF1+= "coalesce(tc.num_chave_nfe,'') as F1_CHVNFE,"+chr(13)
		cTRF1+= "tc.cod_pessoa_transportadora  as F1_FORNECE,"+chr(13)
		cTRF1+= "0 as base_iss,"+chr(13)
		cTRF1+= "0 as F1_ISS,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'IR'"+chr(13)
		cTRF1+= "        and tno.seq_conhecimento  = tc.seq_conhecimento)  as F1_BASEIR,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'IR'"+chr(13)
		cTRF1+= "       and tno.seq_conhecimento  = tc.seq_conhecimento) as F1_VALIRF,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto IN ('CSLL','PCC')"+chr(13)
		cTRF1+= "        and tno.seq_conhecimento  = tc.seq_conhecimento) as F1_BASCSLL,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto IN ('CSLL','PCC')"+chr(13)
		cTRF1+= "        and tno.seq_conhecimento  = tc.seq_conhecimento) as F1_VALCSLL,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_base_calculo),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'INSS'"+chr(13)
		cTRF1+= "        and tno.seq_conhecimento  = tc.seq_conhecimento) as F1_BASEINS,"+chr(13)
		cTRF1+= "(select coalesce(sum(tno.val_retencao),0)"+chr(13)
		cTRF1+= "        from tab_conhecimento_retencao tno"+chr(13)
		cTRF1+= "        where tno.ind_tipo_imposto = 'INSS'"+chr(13)
		cTRF1+= "        and tno.seq_conhecimento  = tc.seq_conhecimento) as F1_INSS,"+chr(13)
		cTRF1+= " 0 as F1_VALIPI,"+chr(13)
		cTRF1+= " 0 as F1_VALIMP6,"+chr(13)
		cTRF1+= " tc.val_pis_recuperar as F1_VALPIS,"+chr(13)
		cTRF1+= " 0 as F1_VALIMP5,"+chr(13)
		cTRF1+= " tc.val_cofins_recuperar as F1_VALCOFI,"+chr(13)
		cTRF1+= " 'N'  as F1_TIPN,"+chr(13)
		cTRF1+= " tc.val_total_frete as F1_VALBRUT"+chr(13)
		cTRF1+= " from tab_conhecimento tc "+chr(13)
		cTRF1+= " inner join tab_pessoa tp on (tp.cod_pessoa = tc.cod_pessoa_transportadora)"+chr(13)
		cTRF1+= " inner join tab_empresa te on (te.cod_empresa = tc.cod_empresa)"+chr(13)
		cTRF1+= " inner join tab_modelo_documento_fiscal tmdf on (tmdf.cod_modelo_documento = tc.cod_modelo_documento)"+chr(13)
		cTRF1+= " inner join tab_natureza_operacao tno on (tno.cod_natureza_operacao = tc.cod_natureza_operacao)"+chr(13)
		cTRF1+= " where tc.dta_entrada  between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"'  and tc.dta_entrada  >= '20201201' "+chr(13)
		If !Empty(Alltrim(MV_PAR03))
			cTRF1+= "and (tc.num_conhecimento = '"+Alltrim(cValToChar(Val(MV_PAR03)))+"') "+chr(13)
		EndIf
		If !Empty(Alltrim(MV_PAR04))
			cTRF1+= "and tc.num_serie = '"+Alltrim(MV_PAR04)+"' "+chr(13)
		EndIf
		If !Empty(Alltrim(cFilAte))
			cTRF1+= "and  (te.num_cnpj = '"+cFilAte+"') "+chr(13)
		Else                             
			cTRF1+= "and (te.num_cnpj = '"+cFilDe+"' )"+chr(13)
		EndIf
		If !Empty(Alltrim(MV_PAR06))
			cTRF1+= "and tp.num_cnpj_cpf  = '"+cPessoa+"' " +chr(13)
		EndIf
	

	//Se escolheu apenas o que não foi importado filtra a query 
	If len(aNotas) > 0 //MV_PAR07 == 1//Somente não importados
		
		cTRF1+= " and cast(tc.num_conhecimento  as varchar(9)) || cast(tc.num_serie as varchar(3)) ||  cast(tp.num_cnpj_cpf as varchar(20)) IN('"
		For _n := 1 to len(aNotas)
			cTRF1 +=   alltrim(aNotas[_n][1]) + Alltrim(Alltrim(anotas[_n][2] ))+Alltrim(Alltrim(anotas[_n][3] ))
			cTRF1 += iif(_n <> len(aNotas), "','","' )") 
		Next _n 

		//cTRF1+= " and nf.serie = '"+Alltrim(Alltrim(QRYTKE->F1_SERIE))+"'  "
		//cTRF1+= " and cast(nf.cpf as varchar(20)) = '"+Alltrim(Alltrim(QRYTKE->F1_CGC))+"' 


		//AADD( aNotas, {  ,QRYTKE->F1_SERIE ,QRYTKE->F1_FORNECE }
	Endif

		cTRF1+= "order by F1_DTDIGIT"+chr(13)

	conout(cTRF1)
	If Select("TRF1") > 0
		TRF1->(DbCloseArea())
	EndIF

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRF1 ), "TRF1", .F., .T.)

Return ()

//------------------------------------------+
// BUSCA INFORMAÇÃO DOS ITENS DA NOTA       |
//------------------------------------------+
Static Function DadosItem ()

	Local cTRD1:= ""
    /*
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
	//cTRD1+= "        round(((nfp.valor/case coalesce(nf.total_produto,0) when 0 then nf.total_servico else nf.total_produto end) * nf.valor_desconto),5) as D1_VALRAT,  "
    cTRD1+= "        case coalesce(nf.total_produto,0) "
    cTRD1+= "          when 0 then 0                   " 
    cTRD1+= "          else round(((nfp.valor/case coalesce(nf.total_produto,0) when 0 then nf.total_servico else nf.total_produto end) * nf.valor_desconto),5)  "
    cTRD1+= "        end as D1_VALRAT,	                                                                                                                         "
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
cTRD1+= "  order by nfp.numero_item " */
/*
	cTRD1+= " select nfp.cod_item as D1_PRODUTO, " 
	cTRD1+= " nfp.val_unitario    as D1_VUNIT  ,  "
	cTRD1+= " nfp.val_total_item  as D1_TOTAL ,  "
	cTRD1+= " nfp.qtd_item    as D1_QUANT,    "
	cTRD1+= " 0  as D1_DESC   ,  "
	cTRD1+= " tt.per_aliquota  as D1_ALIQ   , " 
	cTRD1+= " nf.num_nota     as D1_DOC,      "
	cTRD1+= " nf.dta_emissao    as D1_EMISSAO, " 
	cTRD1+= " cast(nf.num_serie  as varchar(3)) D1_SERIE, " 
	cTRD1+= " tt.per_reducao_base,  "
	cTRD1+= " nfp.val_icms_substituicao   as D1_ICMSRET, " 
	cTRD1+= " nfp.val_base_icms      as D1_BASEICM,  "
	cTRD1+= " nfp.val_frete_fob    as D1_VALFRE,   "
	cTRD1+= " nfp.val_seguro   as D1_SEGURO,  "
	cTRD1+= " (nfp.val_desconto ) as D1_VALDESC, " 
	cTRD1+= " nfp.val_despesa_acessoria as D1_DESPESA, " 
	cTRD1+= " cast(tt.cod_situacao_tributaria as varchar(3)) as D1_CLASFIS, " 
	cTRD1+= " nfp.val_desconto_rateio as D1_VALRAT,	                         "                                                                                                 
	cTRD1+= " nfp.val_ipi      as D1_VALIPI ,  "
	cTRD1+= " tti.per_aliquota as D1_IPI,     "
	cTRD1+= " nf.cod_empresa as F1_EMPRESA,  "
	cTRD1+= " cast(replace(tno.num_cfop,'.','') as varchar (20)) D1_CF,  "
	cTRD1+= " nfp.val_icms     as D1_VALICMS,  "
	cTRD1+= " nfp.val_base_icms_substituicao   as D1_BRICMS, " 
	cTRD1+= " cast(coalesce(nf.ind_finalidade_nota,'N') as varchar(1)) D1_TIPN, "    
	cTRD1+= " cast(p.cod_item      as varchar(20)) as PRODUTO,  "
	cTRD1+= " cast(p.des_item as varchar (50)) DESCRICAO,  "
	cTRD1+= " nfp.seq_item  as D1_ITEM,  "
	cTRD1+= " nfp.val_pis_recuperar as D1_BASEPIS,  "
	cTRD1+= " ttp.per_aliquota        as D1_ALQPIS,  "
	cTRD1+= " nf.val_pis_recuperar    as D1_VALPIS,  "
	cTRD1+= " nfp.val_cofins_recuperar  as D1_BASECOF,  "
	cTRD1+= " nf.val_cofins_recuperar as D1_VALCOF, "
	cTRD1+= " nfp.per_aliquota_cofins as D1_ALQCOF,   "
	cTRD1+= " (select coalesce(sum(tno.val_base_calculo),0) "
	cTRD1+= " from tab_nfe_retencao tno "
	cTRD1+= " where tno.ind_tipo_imposto = 'CSLL' "
	cTRD1+= " and tno.seq_nota  = nfp.seq_nota) as D1_BASECSL, " 
	cTRD1+= " (select coalesce(sum(tno.per_aliquota),0) "
	cTRD1+= " from tab_nfe_retencao tno "
	cTRD1+= " where tno.ind_tipo_imposto = 'CSLL' "
	cTRD1+= " and tno.seq_nota  = nfp.seq_nota) as D1_ALQCSL, "  
	cTRD1+= " (select coalesce(sum(tno.val_retencao),0) "
	cTRD1+= " from tab_nfe_retencao tno "
	cTRD1+= " where tno.ind_tipo_imposto = 'CSLL' "
	cTRD1+= " and tno.seq_nota  = nfp.seq_nota) as D1_VALCSL, "              
	cTRD1+= " nfp.val_base_iss as D1_BASEISS, "
	cTRD1+= " case when p.ind_tipo_item = 'S' then tt.per_aliquota else 0 end as D1_ALIQISS, "
	cTRD1+= " nfp.val_iss as D1_VALISS, "
	cTRD1+= " (select coalesce(sum(tnr.val_base_calculo),0) "
	cTRD1+= " from tab_nfe_retencao tnr "
	cTRD1+= " where tnr.ind_tipo_imposto = 'IR' "
	cTRD1+= " and tnr.seq_nota  = nfp.seq_nota)  as D1_BASEIRR, "
	cTRD1+= " (select coalesce(sum(tnr.per_aliquota),0) "
	cTRD1+= " from tab_nfe_retencao tnr "
	cTRD1+= " where tnr.ind_tipo_imposto = 'IR' "
	cTRD1+= " and tnr.seq_nota  = nfp.seq_nota)  as D1_ALIQIRR, "
	cTRD1+= " (select coalesce(sum(tnr.val_retencao),0) "
	cTRD1+= " from tab_nfe_retencao tnr "
	cTRD1+= " where tnr.ind_tipo_imposto = 'IR' "
	cTRD1+= " and tnr.seq_nota  = nfp.seq_nota)  as    D1_VALIRR, " 
	cTRD1+= " (select coalesce(sum(tnr.val_base_calculo),0) "
	cTRD1+= " from tab_nfe_retencao tnr "
	cTRD1+= " where tnr.ind_tipo_imposto = 'INSS' "
	cTRD1+= " and tnr.seq_nota  = nfp.seq_nota) as D1_BASEINS, "
	cTRD1+= " (select coalesce(sum(tnr.per_aliquota),0) "
	cTRD1+= " from tab_nfe_retencao tnr "
	cTRD1+= " where tnr.ind_tipo_imposto = 'INSS' "
	cTRD1+= " and tnr.seq_nota  = nfp.seq_nota) as D1_ALIQINS, "
	cTRD1+= " (select coalesce(sum(tnr.val_retencao),0) "
	cTRD1+= " from tab_nfe_retencao tnr "
	cTRD1+= " where tnr.ind_tipo_imposto = 'INSS' "
	cTRD1+= " and tnr.seq_nota  = nfp.seq_nota) as D1_VALINS, "
	cTRD1+= " tno.cod_natureza_operacao  as NAT_OP  "
	cTRD1+= " from tab_item_nfe nfp  "
	cTRD1+= " join tab_nota_fiscal_entrada nf on (nf.seq_nota = nfp.seq_nota) " 
	cTRD1+= " join tab_item p on(p.cod_item = nfp.cod_item)  "
	cTRD1+= " join tab_empresa e on (e.cod_empresa = nf.cod_empresa) " 
	cTRD1+= " join tab_tributacao tt on (tt.cod_tributacao = nfp.cod_tributacao_icms) "
	cTRD1+= " left join tab_tributacao tti on (tti.cod_tributacao = nfp.cod_tributacao_ipi) "
	cTRD1+= " left join tab_tributacao ttp on (ttp.cod_tributacao = nfp.cod_tributacao_pis) "
	cTRD1+= " left join tab_tributacao ttc on (ttp.cod_tributacao = nfp.cod_tributacao_cofins) "
	cTRD1+= " join tab_natureza_operacao tno on (tno.cod_natureza_operacao = nfp.cod_natureza_operacao) "//limit 10 "
	cTRD1+= " where nfp.seq_nota = '"+cValToChar(cNotaFis)+"' "//--//  and nf.tipo = 'C' " 
	cTRD1+= "order by nfp.seq_item "*/

	cTRD1:= " select nfp.cod_item as D1_PRODUTO,"  +chr(13)
	cTRD1+= "    nfp.val_unitario    as D1_VUNIT  , " +chr(13)
	cTRD1+= " nfp.val_total_item  as D1_TOTAL , "  +chr(13)
	cTRD1+= " nfp.qtd_item    as D1_QUANT,     "+chr(13)
	cTRD1+= " 0  as D1_DESC   , " +chr(13)
	cTRD1+= " nfp.per_aliquota_icms as D1_ALIQ   ," +chr(13)
	cTRD1+= " nf.num_nota     as D1_DOC,       "+chr(13)
	cTRD1+= " nf.dta_emissao    as D1_EMISSAO,  "+chr(13)
	cTRD1+= " cast(nf.num_serie  as varchar(3)) D1_SERIE," +chr(13) 
	cTRD1+= "  tt.per_reducao_base,   "+chr(13)
	cTRD1+= " nfp.val_icms_substituicao   as D1_ICMSRET,"  +chr(13)
	cTRD1+= " nfp.val_base_icms      as D1_BASEICM,   "+chr(13)
	cTRD1+= " nfp.val_frete_fob    as D1_VALFRE,    "+chr(13)
	cTRD1+= " nfp.val_seguro   as D1_SEGURO,   "+chr(13)
	cTRD1+= " (nfp.val_desconto ) as D1_VALDESC,"  +chr(13)
	cTRD1+= " nfp.val_despesa_acessoria as D1_DESPESA, " +chr(13)
	cTRD1+= " cast(tt.cod_situacao_tributaria as varchar(3)) as D1_CLASFIS, " +chr(13)
	cTRD1+= " nfp.val_desconto_rateio as D1_VALRAT,                          "   +chr(13)         
	cTRD1+= " nfp.val_ipi      as D1_VALIPI ,   "+chr(13)
	cTRD1+= " nfp.per_aliquota_ipi as D1_IPI,    "  +chr(13)
	cTRD1+= " nf.cod_empresa as F1_EMPRESA,   "+chr(13)
	cTRD1+= " cast(replace(tno.num_cfop,'.','') as varchar (20)) D1_CF, "  +chr(13)
	cTRD1+= " nfp.val_icms     as D1_VALICMS,   "+chr(13)
	cTRD1+= " nfp.val_base_icms_substituicao   as D1_BRICMS,"  +chr(13)
	cTRD1+= " cast(coalesce(nf.ind_finalidade_nota,'N') as varchar(1)) D1_TIPN,"  +chr(13)
	cTRD1+= " cast(p.cod_item      as varchar(20)) as PRODUTO,   "+chr(13)
	cTRD1+= " cast(p.des_item as varchar (50)) DESCRICAO,   "+chr(13)
	cTRD1+= " nfp.seq_item  as D1_ITEM,  " +chr(13)
	cTRD1+= " nfp.val_base_pis AS D1_BASIMP6, " +chr(13)
    cTRD1+= "            			 (select coalesce(sum(tnr.val_base_calculo),0)"    +chr(13)      
    cTRD1+= "    							from tab_nfe_retencao tnr     "+chr(13)
    cTRD1+= "            					where tnr.ind_tipo_imposto = 'PIS'"  +chr(13)       
    cTRD1+= "            					and tnr.seq_nota  = nfp.seq_nota)   as D1_BASEPIS, " +chr(13)
    cTRD1+= "     nfp.per_aliquota_pis AS D1_ALQIMP6,"+chr(13)
    cTRD1+= "            			(select coalesce(sum(tnr.per_aliquota),0)        "  +chr(13)
    cTRD1+= "    							from tab_nfe_retencao tnr       "  +chr(13) 
    cTRD1+= "    							where tnr.ind_tipo_imposto = 'PIS'"   +chr(13)      
    cTRD1+= "            					and tnr.seq_nota  = nfp.seq_nota)  as D1_ALQPIS, "+chr(13)
    cTRD1+= "     nfp.val_pis_recuperar AS D1_VALIMP6," +chr(13)
    cTRD1+= "            			(select coalesce(sum(tnr.val_retencao),0)  "   +chr(13)     
    cTRD1+= "    							from tab_nfe_retencao tnr     "+chr(13)
    cTRD1+= "            					where tnr.ind_tipo_imposto = 'PIS'    " +chr(13)    
    cTRD1+= "            					and tnr.seq_nota  = nfp.seq_nota) as    D1_VALPIS, "+chr(13)
    cTRD1+= "      nfp.val_base_cofins AS D1_BASIMP5, "+chr(13)
    cTRD1+= "            			(select coalesce(sum(tnr.val_base_calculo),0)    "   +chr(13)   
    cTRD1+= "    							from tab_nfe_retencao tnr    " +chr(13)
    cTRD1+= "            					where tnr.ind_tipo_imposto = 'COFINS' "     +chr(13)   
    cTRD1+= "            					and tnr.seq_nota  = nfp.seq_nota)  as D1_BASECOF, "+chr(13)
    cTRD1+= "     nfp.per_aliquota_cofins as D1_ALQIMP5,"+chr(13)
    cTRD1+= "            			 (select coalesce(sum(tnr.per_aliquota),0)  "   +chr(13)     
    cTRD1+= "    							from tab_nfe_retencao tnr          "+chr(13)
    cTRD1+= "    							where tnr.ind_tipo_imposto = 'COFINS'         "+chr(13)
    cTRD1+= "            					and tnr.seq_nota  = nfp.seq_nota)  as D1_ALQCOF, "+chr(13)
    cTRD1+= "    nfp.val_cofins_recuperar AS D1_VALIMP5, "+chr(13)
    cTRD1+= "            			(select coalesce(sum(tnr.val_retencao),0) "   +chr(13)      
    cTRD1+= "    							from tab_nfe_retencao tnr     "+chr(13)
    cTRD1+= "            					where tnr.ind_tipo_imposto = 'COFINS'         "+chr(13)
    cTRD1+= "            					and tnr.seq_nota  = nfp.seq_nota) as    D1_VALCOF, "	+chr(13)															
	cTRD1+= " (select coalesce(sum(tno.val_base_calculo),0) "+chr(13)
	cTRD1+= "        from tab_nfe_retencao tno  "+chr(13)
	cTRD1+= "        where tno.ind_tipo_imposto IN ('CSLL','PCC') "+chr(13)
	cTRD1+= "        and tno.seq_nota  = nfp.seq_nota) as D1_BASECSL,"  +chr(13)
	cTRD1+= " (select coalesce(sum(tno.per_aliquota),0)  "+chr(13)
	cTRD1+= "        from tab_nfe_retencao tno  "+chr(13)
	cTRD1+= "        where tno.ind_tipo_imposto IN ('CSLL','PCC') "+chr(13)
	cTRD1+= "        and tno.seq_nota  = nfp.seq_nota) as D1_ALQCSL, " +chr(13)
	cTRD1+= " (select coalesce(sum(tno.val_retencao),0)  "+chr(13)
	cTRD1+= "        from tab_nfe_retencao tno  "+chr(13)
	cTRD1+= "        where tno.ind_tipo_imposto IN ('CSLL','PCC') "  +chr(13)
	cTRD1+= "        and tno.seq_nota  = nfp.seq_nota) as D1_VALCSL,"  +chr(13)
	cTRD1+= " nfp.val_base_iss as D1_BASEISS,  "+chr(13)
	cTRD1+= " nfp.per_aliquota_iss as D1_ALIQISS,"  +chr(13)
	cTRD1+= " nfp.val_iss as D1_VALISS,  "+chr(13)
	cTRD1+= " (select coalesce(sum(tnr.val_retencao),0) " +chr(13)
	cTRD1+= "       from tab_nfe_retencao tnr  "+chr(13)
	cTRD1+= "       where tnr.ind_tipo_imposto = 'ISS' " +chr(13)
	cTRD1+= "       and tnr.seq_nota  = nfp.seq_nota) as ISSRET, "+chr(13)
	cTRD1+= " (select coalesce(sum(tnr.val_base_calculo),0)"  +chr(13)
	cTRD1+= "        from tab_nfe_retencao tnr  "+chr(13)
	cTRD1+= "        where tnr.ind_tipo_imposto = 'IR' " +chr(13)
	cTRD1+= "        and tnr.seq_nota  = nfp.seq_nota)  as D1_BASEIRR,  "+chr(13)
	cTRD1+= " (select coalesce(sum(tnr.per_aliquota),0)  "+chr(13)
	cTRD1+= "        from tab_nfe_retencao tnr  "+chr(13)
	cTRD1+= "        where tnr.ind_tipo_imposto = 'IR' " +chr(13)
	cTRD1+= "        and tnr.seq_nota  = nfp.seq_nota)  as D1_ALIQIRR,"  +chr(13)
	cTRD1+= " (select coalesce(sum(tnr.val_retencao),0)  "+chr(13)
	cTRD1+= "        from tab_nfe_retencao tnr  "+chr(13)
	cTRD1+= "        where tnr.ind_tipo_imposto = 'IR' " +chr(13)
	cTRD1+= "        and tnr.seq_nota  = nfp.seq_nota)  as    D1_VALIRR, " +chr(13)
	cTRD1+= " (select coalesce(sum(tnr.val_base_calculo),0)  "+chr(13)
	cTRD1+= "        from tab_nfe_retencao tnr  "+chr(13)
	cTRD1+= "        where tnr.ind_tipo_imposto = 'INSS'  "+chr(13)
	cTRD1+= "        and tnr.seq_nota  = nfp.seq_nota) as D1_BASEINS, " +chr(13)
	cTRD1+= " (select coalesce(sum(tnr.per_aliquota),0)  "+chr(13)
	cTRD1+= "        from tab_nfe_retencao tnr  "+chr(13)
	cTRD1+= "        where tnr.ind_tipo_imposto = 'INSS' " +chr(13)
	cTRD1+= "        and tnr.seq_nota  = nfp.seq_nota) as D1_ALIQINS, " +chr(13)
	cTRD1+= " (select coalesce(sum(tnr.val_retencao),0)  "+chr(13)
	cTRD1+= "        from tab_nfe_retencao tnr  "+chr(13)
	cTRD1+= "        where tnr.ind_tipo_imposto = 'INSS'"  +chr(13)
	cTRD1+= "        and tnr.seq_nota  = nfp.seq_nota) as D1_VALINS,"  +chr(13)
	cTRD1+= " tno.cod_natureza_operacao  as NAT_OP "+chr(13)
	cTRD1+= " from tab_item_nfe nfp   "+chr(13)
	cTRD1+= " join tab_nota_fiscal_entrada nf on (nf.seq_nota = nfp.seq_nota)" +chr(13) 
	cTRD1+= " join tab_item p on(p.cod_item = nfp.cod_item)   "+chr(13)
	cTRD1+= " join tab_empresa e on (e.cod_empresa = nf.cod_empresa) " +chr(13)
	cTRD1+= " join tab_tributacao tt on (tt.cod_tributacao = nfp.cod_tributacao_icms)  "+chr(13)
	cTRD1+= " join tab_natureza_operacao tno on (tno.cod_natureza_operacao = nfp.cod_natureza_operacao)"  +chr(13)
	cTRD1+= "  where nfp.seq_nota = '"+cValToChar(cNotaFis)+"' "+chr(13)
	cTRD1+= " order by nfp.seq_item "+chr(13)

	conout(cTRD1)
	
	If Select("TRD1") > 0
		TRD1->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRD1), "TRD1", .F., .T.)

Return()

//------------------------------------------+
// BUSCA INFORMAÇÃO DO FORNECEDOR           |
//------------------------------------------+
Static Function DadosForn()

	Local cTRA2 := ""

/*	cTRA2:= " select p.codigo        as A2_COD,                   cast(p.nome    as varchar(50)) A2_NOME  , cast(p.nome_reduzido as varchar(50)) A2_NREDUZ, "
	cTRA2+= "        cast(p.endereco as varchar (50)) A2_END,     cast(p.bairro  as varchar(50)) A2_BAIRRO, cast(p.cidade        as varchar(50)) A2_MUN,    "
	cTRA2+= "        cast(p.estado   as varchar  (2)) A2_UF ,     cast(p.cep     as varchar(11)) A2_CEP   , cast(p.tipo_pessoa   as varchar(50)) A2_TIPO,   "
	cTRA2+= "        cast(p.cpf      as varchar (20)) A2_CGC,     cast(null      as varchar (3)) A2_DDD   , cast(p.fone          as varchar(20)) A2_TEL,    "
	cTRA2+= "        cast(p.contato  as varchar (45)) A2_CONTATO, cast(inscr_est as varchar(20)) A2_INSCR , cast(p.municipio     as varchar (7)) A2_COD_MUN "
	cTRA2+= "   from pessoa p "
	cTRA2+= "  where p.cpf = '"+Alltrim(TRF1->F1_CGC)+"' "*/

	
	cTRA2:= " select p.cod_pessoa as A2_COD,  "                 
    cTRA2+= " cast(p.nom_pessoa    as varchar(50)) A2_NOME  ," 
    cTRA2+= " cast(p.nom_fantasia as varchar(50)) A2_NREDUZ, "
	cTRA2+= " cast(p.des_logradouro as varchar (50)) A2_END,  "   
    cTRA2+= " cast(p.nom_bairro  as varchar(50)) A2_BAIRRO, "
    cTRA2+= " cast(c.nom_cidade        as varchar(50)) A2_MUN, "   
	cTRA2+= " cast(e.sgl_estado   as varchar  (2)) A2_UF ,     "
    cTRA2+= " cast(p.num_cep     as varchar(11)) A2_CEP   , "
    cTRA2+= " case when length(p.num_cnpj_cpf) <=11 then 'F' else 'J' end A2_TIPO, "  
	cTRA2+= " cast(p.num_cnpj_cpf      as varchar (20)) A2_CGC,    "
    cTRA2+= " cast(null      as varchar (3)) A2_DDD   , "
    cTRA2+= " cast(p.num_telefone_1          as varchar(20)) A2_TEL,"    
	cTRA2+= " cast(p.nom_contato  as varchar (45)) A2_CONTATO, "
    cTRA2+= " cast(p.num_ie_rg as varchar(20)) A2_INSCR , "
    cTRA2+= " cast(d.cod_uf || d.cod_municipio      as varchar (7)) A2_COD_MUN "
    cTRA2+= " from tab_pessoa p "
    cTRA2+= " inner join tab_cidade c on (p.cod_cidade = c.cod_cidade)"
    cTRA2+= " inner join tab_estado e on (e.cod_estado = c.cod_estado)"
    cTRA2+= " left join tab_municipio_ibge d on (d.seq_municipio_ibge = c.seq_municipio_ibge)"
    cTRA2+= " where p.num_cnpj_cpf = '"+Alltrim(TRF1->F1_CGC)+"' "

	If Select("TRA2") > 0
		TRA2->(DbCloseArea())
	EndIF
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRA2), "TRA2", .F., .T.)

Return()

//-------------------------------	-----------+
// BUSCA INFORMAÇÃO DO PRODUTO              |
//------------------------------------------+
Static Function DadosProd()

	Local cTRB1    := ""

	/*cTRB1:=  " select cast(produto.codigo               as varchar(255)) B1_PRODUTO, "
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
	cTRB1+=  " where produto.grid = '" + cValToChar(cProduto) + "'"*/
	
	cTRB1:=  " select distinct cast(ti.cod_item  AS varchar(15)) as B1_PRODUTO, " 
    cTRB1+=  " ti.des_item as B1_DESC, "
    cTRB1+=  " ti.ind_tipo_item as B1_TIPO, " 
    cTRB1+=  " tgi.cod_grupo_item as B1_GRUPO, "
    cTRB1+=  " tu.sgl_unidade as B1_UM, "
    cTRB1+=  " tgi.des_grupo_item as B1_NOMEG,"
    cTRB1+=  " tn.cod_ncm as B1_POSIPI,"
    cTRB1+=  " ti.cod_item as B1_GRID,"
    cTRB1+=  " tcce.des_classificacao as B1_CONTA,"
    cTRB1+=  " tn.cod_cest as B1_CEST"
    cTRB1+=  " from tab_item ti"
    cTRB1+=  " inner join tab_subgrupo_item tsi on (tsi.cod_subgrupo_item = ti.cod_subgrupo_item)"
    cTRB1+=  " inner join tab_grupo_item tgi on (tgi.cod_grupo_item = tsi.cod_grupo_item)"
    cTRB1+=  " inner join tab_unidade tu on (tu.cod_unidade = ti.cod_unidade)"
    cTRB1+=  " left join tab_ncm tn on (tn.seq_ncm = ti.seq_ncm)"
    cTRB1+=  " left join tab_item_empresa tie on (tie.cod_item = ti.cod_item)"
    cTRB1+=  " left join tab_ctb_conta_empresa tcce on (tcce.seq_conta = tie.seq_conta) "
    cTRB1+=  " where ti.cod_item = '" + cValToChar(cProduto) + "' "
	
	
	
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRB1), "TRB1", .F., .T.)

Return ()

//------------------------------------------+
// BUSCA INFORMAÇÃO DA DUPLICATA            |
//------------------------------------------+
Static Function DadosDupl ()

	Local cTRE2 := ""

	/*cTRE2:= "  select mm.codigo AS CODNAT, cast(split_part(m.documento, '/', 1)as varchar(10)) E2_NUM , p.codigo, e.codigo, m.data  AS E2_EMISSAO, "
	cTRE2+= "         split_part(cast(m.documento as varchar(10)), '/', 2) E2_PARCELA, "
	cTRE2+= "         m.vencto AS E2_VENCTO, m.valor AS E2_VALOR,           "
	cTRE2+= "         cast(mm.nome  AS varchar(50)) E2_HIST, cast(p.cpf  as varchar (20)) E2_CNPJ, m.empresa, "
	cTRE2+= "         cast(split_part(cc.codigo, '.', 2)as varchar(9)) D1_CC, cc.nome "//Centro de Custo
	cTRE2+= "    from movto m "
	cTRE2+= "        join 	 mm on (mm.grid = m.motivo and mm.tipo_movto = 1)"
	cTRE2+= "        join pessoa p  on (p.grid = m.pessoa) "
	cTRE2+= "        join empresa e on (e.grid = m.empresa) "
	cTRE2+= "        left join movto_centro_custo mcc on (mcc.movto = m.grid) and mcc.perc_rateio = 100 " //Centro de Custo
	cTRE2+= "        left join centro_custo cc on (mcc.centro_custo = cc.grid) "//Centro de Custo
	cTRE2+= "   where split_part(cast(m.documento as varchar(10)), '/', 1) = '"+cValToChar(TRF1->F1_DOC)+"'" /* nota_fiscal.numero_nota *//*
	cTRE2+= "     and m.conta_creditar LIKE '2.1.%'       "
	cTRE2+= "     and p.cpf = '"+ALLTRIM(TRF1->F1_CGC)+"' "
	cTRE2+= "     and m.empresa = '"+Alltrim(Str(TRF1->EMPRESA))+"' "
	
	If !Empty(ALLTRIM(TRF1->F1_MLID))
	  cTRE2+= "     and m.mlid = '"+ALLTRIM(TRF1->F1_MLID)+"' "
	EndIf
    cTRE2+=	"   order by m.vencto "*/

	cTRE2:= "select "
    cTRE2+= "case when tnfe.seq_movimento_caixa is null then 0  else 405 end as CODNAT, "  
    cTRE2+= "tnfe.num_nota as E2_NUM,         "
    cTRE2+= "tnfe.cod_pessoa_fornecedor as codigo,"
    cTRE2+= "tnfe.cod_empresa as codigo, "
    cTRE2+= "tnfe.dta_emissao as E2_EMISSAO,"        
    cTRE2+= "coalesce(tpn.seq_parcela,0) as E2_PARCELA,"   
    cTRE2+= "case when tpn.dta_vencimento is null then tnfe.dta_entrada else tpn.dta_vencimento end as E2_VENCTO, "         
    cTRE2+= "case when (coalesce(tpn.val_parcela,0) = 0) then tnfe.val_total_nota else tpn.val_parcela end as E2_VALOR, "       
    cTRE2+= "tno.des_natureza_operacao as E2_HIST, "        
    cTRE2+= "tp.num_cnpj_cpf as E2_CNPJ,"         
    cTRE2+= "tnfe.cod_empresa as empresa,"        
    cTRE2+= "'' as D1_CC "         										
    cTRE2+= "from tab_nota_fiscal_entrada tnfe "            													   
    cTRE2+= "inner join tab_natureza_operacao tno on (tno.cod_natureza_operacao = tnfe.cod_natureza_operacao) "       
    cTRE2+= "inner join tab_pessoa tp on (tp.cod_pessoa = tnfe.cod_pessoa_fornecedor) "        
    cTRE2+= "left  join tab_parcela_nfe tpn on (tpn.seq_nota = tnfe.seq_nota) "  
    cTRE2+= "where tno.ind_gera_financeiro  = 'S' "																						  
    cTRE2+= "    and  tnfe.NUM_NOTA = '"+ALLTRIM(TRF1->F1_DOC)+"'"//-- /* nota_fiscal.numero_nota */
    cTRE2+= "    and ((tp.num_cnpj_cpf = '"+ALLTRIM(TRF1->F1_CGC)+"' ))"
    cTRE2+= "    and tnfe.cod_empresa = '"+Alltrim(Str(TRF1->EMPRESA))+"' "
    
	If !Empty(ALLTRIM(TRF1->F1_MLID))
       cTRE2+= "         and tnfe.seq_nota = '"+ALLTRIM(TRF1->F1_MLID)+"' "
    EndIf
    
	cTRE2+= "         order by tpn.dta_vencimento "

	conout('cTRE2')
	conout(cTRE2)
	If Select("TRE2") > 0
		TRE2->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRE2), "TRE2", .F., .T.)

Return()

//------------------------------------------+
// GRAVA A INFORMAÇÃO DO PRODUTO            |
//------------------------------------------+
Static Function GravProd()
	Private cTipo   := ""
	Private cGrupo  := ""
	Private _cProd  := ""
	Private _cDescP := ""
	Private _cConta := SPACE(20)

	If Alltrim(STR(TRB1->B1_GRID)) == Alltrim(cValToChar(cProduto))
		// BUSCA OS CONTA DO PRODUTO
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '03' AND ZZ9_CAMP1 = '"+Alltrim(TRB1->B1_CONTA)+"' "
		conout(cQuery)
		If (Select ("QR03")<> 0)
			QR03->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR03"

		DbSelectArea("QR03")
		While !EOF()
			_cConta:= Alltrim(QR03->ZZ9_CAMP2)
			QR03->(DbSkip())
		EndDo
		QR03->(DbCloseArea())

		// BUSCA OS TIPOS DE PRODUTO
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '02' AND ZZ9_CAMP1 = '"+(Alltrim(TRB1->B1_TIPO))+"' "
		conout(cQuery)
		If (Select ("QR02")<> 0)
			QR02->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR02"

		DbSelectArea("QR02")
		While !EOF()
			cTipo:= Alltrim(QR02->ZZ9_CAMP2)
			QR02->(DbSkip())
		EndDo
		QR02->(DbCloseArea())

		// BUSCA CÓDIGO DE PRODUTO ESPECIFICO
		cGrupo:= StrZero(TRB1->B1_GRUPO,4)
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = 'B1' AND ZZ9_CAMP4 = '"+(Alltrim(TRB1->B1_PRODUTO))+"' "
		conout(cQuery)
		If (Select ("QRB1")<> 0)
			QRB1->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QRB1"

		DbSelectArea("QRB1")
		While !EOF()
			_cProd := Alltrim(QRB1->ZZ9_CAMP1)
			_cDescP:= Alltrim(QRB1->ZZ9_CAMP2)
			_cConta:= Alltrim(QRB1->ZZ9_CAMP3)
			QRB1->(DbSkip())
		EndDo

		QRB1->(DbCloseArea())

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
				SB1->(DbCloseArea())
				//			FWrite(nHandle, "CADASTRO PRODUTO | AVISO | COD PRODUTO: "+Alltrim(TRB1->B1_PRODUTO)+ " - "+ Alltrim(TRB1->B1_DESC) + "| GRAVADO "+ CRLF)
				//FWrite(nHandle, "CADASTRO PRODUTO | AVISO | COD PRODUTO: "+Alltrim(_cProd)+ " - "+ Alltrim(TRB1->B1_DESC) + "| GRAVADO COM SUCESSO"+ CRLF)
			Else
				//			FWrite(nHandle, "CADASTRO PRODUTO | AVISO | COD PRODUTO: "+Alltrim(TRB1->B1_PRODUTO)+ " - "+ Alltrim(TRB1->B1_DESC)+ " | PRODUTO JA CADASTRADO" + CRLF)
				//FWrite(nHandle, "CADASTRO PRODUTO | AVISO | COD PRODUTO: "+Alltrim(_cProd)+ " - "+ Alltrim(TRB1->B1_DESC)+ " | GRAVADO COM SUCESSO" + CRLF)
				lProduto := .T. //.F.
				//lProduto1:= .T. //.F.
			EndIf
		Else
			//		FWrite(nHandle, "CADASTRO PRODUTO |ERRO  | COD PRODUTO: "+Alltrim(TRB1->B1_PRODUTO)+ " - "+ Alltrim(TRB1->B1_DESC)+ " | PRODUTO NAO CADASTRADO" + CRLF)
			//FWrite(nHandle, "CADASTRO PRODUTO |ERRO  | COD PRODUTO: "+Alltrim(_cProd)+ " - "+ Alltrim(TRB1->B1_DESC)+ " | PRODUTO NAO CADASTRADO" + CRLF)
			lProduto := .F.
			//lProduto1:= .F.
		EndIf
	EndIf

	// lProduto:= .F.

	cQuery := " SELECT * FROM " + RETSQLNAME("SB1") + " (NOLOCK) "
	cQuery += " WHERE B1_COD = '"+(Alltrim(TRB1->B1_PRODUTO))+"' "
	conout(cQuery)
	If (Select ("QRBS")<> 0)
		QRBS->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QRBS"

	DbSelectArea("QRBS")
	While QRBS->(!EOF())
		lProduto:= .T.
		QRBS->(DbSkip())
	EndDo

Return(lProduto)

//------------------------------------------+
// GRAVA INFORMAÇÃO DO FORNECEDOR           |
//------------------------------------------+
Static Function GravForn()

	Private cNum := ""
	Private cCEP := Alltrim(TRA2->A2_CEP)

	DbSelectArea("TRA2")
	TRA2->(DbGoTop())
	While TRA2->(!EOF())
		oXagCon:ConecPRT()
		If lFornece
			DbSelectArea("SA2")
			DbSetOrder(3)

			If !DbSeek(xFilial("SA2")+cCGC)
				cCEP := STRTRAN(cCEP,".","")
				cCEP := STRTRAN(cCEP,"-","")
				cCEP := STRTRAN(cCEP,"/","")

				//Cria a nova conta para Fornecedor
				_cConta:= GeraCCont(alltrim(NoAcento(AnsiToOem(IIf (Alltrim(TRA2->A2_NOME) <> "", TRA2->A2_NOME, TRA2->A2_NREDUZ)))),"SA2")

				DbSelectArea("SA2")
				If alltrim(_cConta) <> ''
					Reclock("SA2",.T.)
					SA2->A2_CLASSIF    := "00"
					SA2->A2_COD        := GETSXENUM('SA2','A2_COD') //NextNumero("SA2",1,"A2_COD",.T., )
					ConfirmSX8()

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
					FWrite(nHandle, "CADASTRO FORNECEDOR | AVISO | COD FORNEC "+cCGC+ " | DESCRICAO "+ TRA2->A2_NOME + " | GRAVADO COM SUCESSO" +CRLF)

				Else
					FWrite(nHandle, "CADASTRO FORNECEDOR | ERRO | COD FORNEC "+cCGC+ " | DESCRICAO "+ TRA2->A2_NOME + " | NÃO CRIADO, ERRO NA CONTA CONTABIL -> "+cLog +CRLF)
					lFornece1 := .F.
					lFornece  := .F.
				Endif
			EndIf
		Else
			Fwrite(nHandle, "CADASTRO FORNECEDOR | ERRO  | COD FORNEC "+cCGC+ " | DESCRICAO "+ TRA2->A2_NOME + " | FORNECEDOR NAO CADASTRADO" + CRLF)
			lFornece1 := .F.
			lFornece  := .F.
		EndIf
		SA2->(DbCloseArea())
		DbSelectArea("TRA2")
		DbSkip()
	EndDo
	TRA2->(DbCloseArea())

Return()

//------------------------------------------+
// GRAVA INFORMAÇÃO DO CLIENTE - DEVOLUCAO  |
//------------------------------------------+
Static Function GravClie()

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
			Fwrite(nHandle, "CADASTRO DE CLIENTE | AVISO  | CLIENTE " +cCGC+ " | DESCRICAO "+ TRA2->A2_NOME + " | CLIENTE GRAVADO COM SUCESSO DE NOTA DEVOL. " + CRLF)
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
		SA1->(DbCloseArea())
		DbSelectArea("TRA2")
		DbSkip()
	EndDo

	TRA2->(DbCloseArea())

Return()

//------------------------------------------+
// GRAVA INFORMAÇÃO DA CAPA DA NOTA         |
//------------------------------------------+
Static Function GravCapa(cCNPJ)

	Private cCodFor := ""
	Private cLojaFor:= ""
	Private cEstFor := ""
	Private lSF3    := .F.
	Private cTipoNota   := ""
	Private cPrefixoDoc := SubStr((TRF1->F1_SERIE),1,3) // ribas filial + serie

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

	cDocumento:= PADL(alltrim(TRF1->F1_DOC),9,'0')//cValtoChar(StrZero(TRF1->F1_DOC,9))
	cParEspec:= "NF"

	// BUSCA MODELO DA NF
	cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
	cQuery += " WHERE ZZ9_TABELA = '04' AND ZZ9_CAMP1 = '"+(Alltrim(TRF1->MODELO))+"' AND ZZ9_CAMP3 = 'E' "
	conout(cQuery)
	If (Select ("QR04")<> 0)
		QR04->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QR04"

	DbSelectArea("QR04")
	While !EOF()
		cParEspec:= QR04->ZZ9_CAMP2
		QR04->(DbSkip())
	EndDo
	QR04->(DbCloseArea())

	//cTipoNota :=  Alltrim(TRF1->F1_TIPN)
	//if Alltrim(TRF1->F1_TIPN) <> "D"
	//  cTipoNota := "N"
	//endif

	iF TRF1->MODELO == 57 
		cParEspec := 'DACTE'
	Endif 

	DbSelectArea("SF1")
	DbSetOrder(1)
	If !DbSeek(_cXFilial+Alltrim(cDocumento)+Alltrim(cValTochar(TRF1->F1_SERIE))+cCodFor+Alltrim(cLojaFor)+alltrim(TRF1->F1_TIPN))
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
		SF1->F1_VALIMP5  := TRF1->F1_VALIMP5
		SF1->F1_VALIMP6  := TRF1->F1_VALIMP6
		SF1->F1_VALCOFI := TRF1->F1_VALCOFI
		SF1->F1_ORIIMP  := "SLAARG1A"
		SF1->F1_VALBRUT := TRF1->F1_VALBRUT
		SF1->F1_PREFIXO := cPrefixoDoc

		cValIss  := TRF1->F1_ISS
		cValIrr  := TRF1->F1_VALIRF
		cValInss := TRF1->F1_INSS
		cValPis  := TRF1->F1_VALPIS
		cValCof  := TRF1->F1_VALCOFI
		cValCsl  := TRF1->F1_VALCSLL

		SF1->(MsUnlock())
		SF1->(DbCloseArea())
		FWrite(nHandle, CRLF)
		FWrite(nHandle, "CAPA DA NOTA        | AVISO | NUM NOTA   "+Alltrim(cDocumento)+ " FORNEC "+ cCodFor  + " | GRAVADA COM SUCESSO" + CRLF)
	EndIf

Return()

//------------------------------------------+
// GRAVA INFORMAÇÃO DOS ITENS DA NOTA       |
//------------------------------------------+
Static Function GravItem(cCNPJ)

	Local cQuery     := ""
	Local cZZ9_CAMP8 := ""
	Local aTemRateio := {}
	Local cD1_RATEIO := ""
	Local lPrdIgual  := .F.
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
	cDocd1 := PADL(alltrim(TRD1->D1_DOC),9,'0')//cValtoChar(StrZero(TRD1->D1_DOC,9))

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
	conout(cQuery)
	If (Select ("QRB1")<> 0)
		QRB1->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QRB1"

	DbSelectArea("QRB1")
	While !EOF()
		_cProd := Alltrim(QRB1->ZZ9_CAMP1)
		QRB1->(DbSkip())
	EndDo

	QRB1->(DbCloseArea())

	cQry := " SELECT *"
	cQry += " FROM " + RetSQLName("SD1") + " (NOLOCK) "
	cQry += " WHERE "+RetSQLName("SD1")+".D_E_L_E_T_ = '' "
	cQry += " AND D1_FILIAL = '"+_cXFilial+"' AND D1_DOC = '"+Alltrim(cDocd1)+"'"
	cQry += " AND D1_SERIE = '"+Alltrim(cValToChar(TRD1->D1_SERIE))+"' AND D1_FORNECE = '"+Alltrim(cCodFor)+"' "
	cQry += " AND D1_LOJA = '"+Alltrim(cLojaFor)+"' "
	//cQry += " AND D1_COD = '"+Alltrim(_cProd)+"' "
	cQry += " AND (D1_ITEM = '"+cValToChar(TRD1->D1_ITEM)+"' OR D1_ITEM = '"+cValToChar(StrZero(TRD1->D1_ITEM,4))+"') "
	conout(cQuery)
	If (Select ("QRY")<> 0)
		QRY->(DbCloseArea())
	EndIf
	TcQuery cQry New Alias "QRY"

	DbSelectArea("QRY")
	While !EOF()
		lSD1:= .T.
		lPrdIgual := Alltrim(QRY->D1_COD) ==  Alltrim(_cProd)
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
	conout(cQuery)
	If (Select ("QR05")<> 0)
		QR05->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QR05"

	DbSelectArea("QR05")
	While !EOF()
		cTES:= Alltrim(QR05->ZZ9_CAMP1)

		cZZ9_CAMP8 := QR05->ZZ9_CAMP8
		if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
			cStatus := ''
		endif

		QR05->(DbSkip())
	EndDo
	QR05->(DbCloseArea())

	//----------------------------------//
	cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
	cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD1->D1_CLASFIS)+"' AND ZZ9_CAMP7 = 'E' "
	conout(cQuery)
	If (Select ("QR05")<> 0)
		QR05->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QR05"

	DbSelectArea("QR05")
	While !EOF()
		cTES:= Alltrim(QR05->ZZ9_CAMP1)

		cZZ9_CAMP8 := QR05->ZZ9_CAMP8
		if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
			cStatus := ''
		endif

		QR05->(DbSkip())
	EndDo
	QR05->(DbCloseArea())

	//----------------------------------//
	If TRD1->D1_VALICMS == 0
		//----------------------------------//
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' "
		cQuery += " AND ZZ9_CAMP3  = 'D1_VALICMS==0' AND ZZ9_CAMP7 = 'E' "
		conout(cQuery)
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		While !EOF()
			cTES := Alltrim(QR05->ZZ9_CAMP1)

			cZZ9_CAMP8 := QR05->ZZ9_CAMP8
			if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
				cStatus := ''
			endif

			QR05->(DbSkip())
		EndDo
		QR05->(DbCloseArea())

		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD1->D1_CLASFIS)+"' "
		cQuery += " AND ZZ9_CAMP3  = 'D1_VALICMS==0' AND ZZ9_CAMP7 = 'E' "
		conout(cQuery)
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

			cZZ9_CAMP8 := QR05->ZZ9_CAMP8
			if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
				cStatus := ''
			endif

			QR05->(DbSkip())
		EndDo
		QR05->(DbCloseArea())


		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD1->D1_CLASFIS)+"' "
		cQuery += " AND ZZ9_CAMP3  = 'D1_VALICMS==0' AND ZZ9_CAMP7 = 'E' "

		If (TRD1->D1_ICMSRET > 0)
			cQuery += " AND ZZ9_CAMP9 = 'D1_ICMSRET>0' "
		Else
			cQuery += " AND ZZ9_CAMP9 = 'D1_ICMSRET==0' "
		EndIf
		conout(cQuery)
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

			cZZ9_CAMP8 := QR05->ZZ9_CAMP8
			if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
				cStatus := ''
			endif

			QR05->(DbSkip())
		EndDo
		QR05->(DbCloseArea())

	Else

		//----------------------------------//
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"'  "
		cQuery += " AND ZZ9_CAMP4  = 'D1_VALICMS>0' AND ZZ9_CAMP7 = 'E' "
		conout(cQuery)
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

			cZZ9_CAMP8 := QR05->ZZ9_CAMP8
			if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
				cStatus := ''
			endif

			QR05->(DbSkip())
		EndDo
		QR05->(DbCloseArea())

		//----------------------------------//
		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD1->D1_CLASFIS)+"' "
		cQuery += " AND ZZ9_CAMP4  = 'D1_VALICMS>0' AND ZZ9_CAMP7 = 'E' "
		conout(cQuery)
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		While !EOF()
			cTES := Alltrim(QR05->ZZ9_CAMP1)

			cZZ9_CAMP8 := QR05->ZZ9_CAMP8
			if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
				cStatus := ''
			endif

			QR05->(DbSkip())
		EndDo
		QR05->(DbCloseArea())

		cQuery := " SELECT * FROM " + RETSQLNAME("ZZ9") + " (NOLOCK) "
		cQuery += " WHERE ZZ9_TABELA = '05' AND ZZ9_CAMP2 = '"+(Alltrim(cCfop))+"' AND ZZ9_CAMP5 =  '"+Alltrim(TRD1->D1_CLASFIS)+"' "
		cQuery += " AND ZZ9_CAMP3  = 'D1_VALICMS>0' AND ZZ9_CAMP7 = 'E' "

		If (TRD1->D1_ICMSRET > 0)
			cQuery += " AND ZZ9_CAMP9 = 'D1_ICMSRET>0' "
		Else
			cQuery += " AND ZZ9_CAMP9 = 'D1_ICMSRET==0' "
		EndIf
		conout(cQuery)
		If (Select ("QR05")<> 0)
			QR05->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "QR05"

		DbSelectArea("QR05")
		While !EOF()
			cTES:= Alltrim(QR05->ZZ9_CAMP1)

			cZZ9_CAMP8 := QR05->ZZ9_CAMP8
			if Alltrim(QR05->ZZ9_CAMP6) == "S" .And. (Empty(cZZ9_CAMP8) .Or. &(cZZ9_CAMP8))
				cStatus := ''
			endif

			QR05->(DbSkip())
		EndDo
		QR05->(DbCloseArea())
	EndIf
	
	//Spiller - Verifica se a Nota Possui Rateio, Grava array aTemRateio com as informações:
	// [1] - Centro de Custo
	// [2] - % de rateio
	// [3] - Valor Total de Rateio
	aTemRateio := DadosRatCC()
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

		Begin Transaction
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
		SD1->D1_ORIIMP  := "SLAARG1A"
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
		If TRD1->D1_VALISS > 0 
			SD1->D1_VALISS  := TRD1->D1_VALISS
		Else
			SD1->D1_VALISS  := TRD1->ISSRET
		Endif 
		SD1->D1_BASEINS := TRD1->D1_BASEINS
		SD1->D1_ALIQINS := TRD1->D1_ALIQINS
		SD1->D1_VALINS  := TRD1->D1_VALINS
		SD1->D1_VALIPI  := TRD1->D1_VALIPI
		SD1->D1_IPI     := TRD1->D1_IPI
		SD1->D1_CLASFIS := TRD1->D1_CLASFIS
		iF TRD1->D1_VALPIS > 0 
			SD1->D1_BASEPIS := TRD1->D1_BASEPIS
			SD1->D1_ALQPIS  := TRD1->D1_ALQPIS
			SD1->D1_VALPIS  := TRD1->D1_VALPIS
		Endif 
		If TRD1->D1_VALCOF > 0 
			SD1->D1_BASECOF := TRD1->D1_BASECOF
			SD1->D1_ALQCOF  := TRD1->D1_ALQCOF
			SD1->D1_VALCOF  := TRD1->D1_VALCOF
		Endif 
		iF TRD1->D1_VALIMP6 > 0 
			SD1->D1_BASIMP6  := TRD1->D1_BASIMP6
			SD1->D1_ALQIMP6  := TRD1->D1_ALQIMP6
			SD1->D1_VALIMP6  := TRD1->D1_VALIMP6
		Endif 
		iF TRD1->D1_VALIMP5 > 0 
			SD1->D1_BASIMP5  := TRD1->D1_BASIMP5
			SD1->D1_ALQIMP5  := TRD1->D1_ALQIMP5
			SD1->D1_VALIMP5  := TRD1->D1_VALIMP5
		Endif 
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
		//SD1->(DbCloseArea())
		End Transaction	
		//Se existir Rateio, Grava tabela SDE
		If cD1_RATEIO == "1" .and. len(aTemRateio) > 1
			SLAGrvRat(aTemRateio)
		Endif
		
		SDE->(DbCloseArea())
		SD1->(DbCloseArea())
		
		FWrite(nHandle, "ITENS DA NOTA       | AVISO | ITEM  "+cValToChar(nItem)+ " | PRODUTO "+ TRD1->PRODUTO +" | NF: "+ Alltrim(cDocd1) + " | GRAVADO COM SUCESSO" + CRLF)
	Else
		If lPrdIgual
			FWrite(nHandle,     "ITENS DA NOTA       | AVISO | ITEM  "+cValToChar(nItem)+ " | PRODUTO "+ TRD1->PRODUTO +" | NF: "+ Alltrim(cDocd1) + " | ITEM DA NF JA INSERIDO"+ CRLF)
		Else
			FWrite(nHandle,     "ITENS DA NOTA       | ERRO | ITEM  "+cValToChar(nItem)+ " | PRODUTO "+ TRD1->PRODUTO +" | NF: "+ Alltrim(cDocd1) + " | ITEM DA NF JA INSERIDO COM PRODUTO DIFERENTE."+ CRLF)
			lItemnf:= .F.
			lErroProd := .T.
			MsgAlert("Houve alteração no item"+cValToChar(nItem)+" da NF "+ Alltrim(cDocd1)+", Caso esteja correto, exclua a nota no protheus e importe novamente." )
		Endif
		
	EndIf
	QRY->(DbCloseArea())

Return()

//------------------------------------------+
// GRAVA INFORMAÇÃO DAS DUPLICATAS          |
//------------------------------------------+
Static Function GravDupl(cCGC)

	Local  cQuery       := ""
	Private cPrefixo	:= SubStr((TRF1->F1_SERIE),1,3) // ribas filial + serie
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

	cDocE2:= PADL(alltrim(TRF1->F1_DOC),9,'0')//cValtoChar(StrZero(TRF1->F1_DOC,9))

	cQuery := " SELECT *"
	cQuery += " FROM "+RetSQLName("SE2") + " (NOLOCK) "
	cQuery += " WHERE "+RetSQLName("SE2")+".D_E_L_E_T_ = ''"
	cQuery += " AND E2_FILIAL = '' AND E2_PREFIXO = '"+Alltrim(cValToChar(cPrefixo))+"' "
	cQuery += " AND E2_NUM = '"+Alltrim(cDocE2)+"' AND  E2_FORNECE = '"+Alltrim(cCodFor)+"' AND E2_LOJA = '"+Alltrim(cLojaFor)+"'"
	cQuery += " AND E2_PARCELA = '"+Alltrim(cValToChar(nParcela))+"' "
	conout(cQuery)
	If (Select ("QRY1")<> 0)
		QRY1->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QRY1"

	DbSelectArea("QRY1")
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
		SE2->E2_ORIIMP  	:= "SLAAGR1A"
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
		FWrite(nHandle, "DUPLICATAS          | ERRO  | NUM DUPLICATA "+Alltrim(cDocE2)+ " | FORNEC "+ cCodFor  + " | NAO IMPORTADA, JA EXISTENTE NO PROTHEUS" + CRLF)
		lSE2:= .F.
	EndIf

	//Quando for Motivo 405 deve baixar o título automáticamente
	IF TRE2->CODNAT == 405
		BaixarTit()
	Endif

	SE2->(DbCloseArea())

	cValIss := 0
	cValIrr := 0
	cValPis := 0
	cValCof := 0
	cValCsl := 0

	QRY1->(DbCloseArea())

Return()

//Geração de Conta Contabil automaticamente
Static Function GeraCCont(xRazao,xTipo)

	Local nOpcAuto :=0
	Local nX
	Local oCT1
	Local aLog
	Local _cConta := ""

	Default xTipo = "SA2"

	cLog   := ""

	Static __oModelAut //:= NIL //variavel oModel para substituir msexecauto em MVC

	//Se for conta de Fornecedor
	If xTipo ==  "SA2"

		__oModelAut := FWLoadModel('CTBA020')
		nOpcAuto:=3
		__oModelAut:SetOperation(nOpcAuto) // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
		__oModelAut:Activate() //ativa modelo

		DbSelectArea('CT1')
		RegtoMemory('CT1')
		_cConta := ALLTRIM(ProxForn())

		oCT1 := __oModelAut:GetModel('CT1MASTER') //Objeto similar enchoice CT1
		oCT1:SETVALUE('CT1_CONTA',_cConta/*'211016859'*/)
		oCT1:SETVALUE('CT1_DESC01',SUBSTR( ALLTRIM(xRazao),1,40))
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
		
		oCT1:SETVALUE('CT1_ORIIMP','PASSIVO') 
		oCT1:SETVALUE('CT1_GRUPO','00000035') 
		oCT1:SETVALUE('CT1_XSGRUP','00000035') 

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
			//AutoGRLog(cLog) //grava log para exibir com funcao mostraerro
			//mostraerro()
			_cConta := ""
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
	Local _cRetConta := ""

	If cEmpAnt == '44'
		cQuery += " SELECT SUBSTRING(MAX(CT1_CONTA),1,7) AS CT1_CTASUP,  MAX(CAST(SUBSTRING(CT1_CONTA,8,8) AS FLOAT) ) +1 AS CT1_CONTA FROM CT1"+cEmpant+"0 (NOLOCK) "
		cQuery += " WHERE CT1_CONTA  LIKE '2101010%' "
	Else
		cQuery += " SELECT SUBSTRING(MAX(CT1_CONTA),1,5) AS CT1_CTASUP,  MAX(CAST(SUBSTRING(CT1_CONTA,6,8) AS FLOAT) ) + 1 AS CT1_CONTA FROM CT1"+cEmpant+"0 (NOLOCK) "
		cQuery += " WHERE CT1_CONTA  LIKE '21101%' "
	Endif
	cQuery += " AND D_E_L_E_T_ = '' "
	conout(cQuery)
	If Select(cAliasQry) <> 0
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasQry)

	_cRetConta := alltrim( (cAliasQry)->CT1_CTASUP ) + alltrim(str((cAliasQry)->CT1_CONTA))

	If Select(cAliasQry) <> 0
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbCloseArea())
	Endif


Return _cRetConta


//------------------------------------------+
// BUSCA INFORMAÇÃO DE RATEIO POR CC        |
//------------------------------------------+
Static Function DadosRatCC()

	Local cTRERAT := ""
	Local aRetRAT := {}
	Local nTotalTit := 0 
	Local _i        := 0
	
	oXagCon:ConecEMS()

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
   /* cTRERAT:= "  select "
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
	cTRERAT+= "     and m.empresa = '"+Alltrim(Str(TRF1->EMPRESA))+"' "*/

	
	cTRERAT := "     select tod.num_doc_despesa as E2_NUM, "
    cTRERAT+= "     coalesce(tcc.des_centro_custo,'') as D1_CC, "
    cTRERAT+= "     sum(trd.val_rateio) as VALRAT "
	cTRERAT+= "     from tab_outras_despesas tod "
	cTRERAT+= "     left join tab_rateio_despesa trd on (tod.seq_despesa = trd.seq_despesa) "
	cTRERAT+= "     left join tab_centro_custo tcc on (tcc.cod_centro_custo = trd.cod_centro_custo) "
	cTRERAT+= "     inner join tab_pessoa tp on (tp.cod_pessoa = tod.cod_pessoa_favorecido) "
	cTRERAT+= "     where tod.num_doc_despesa = '"+cValToChar(TRF1->F1_DOC)+"' "
	cTRERAT+= "     and (tp.num_cnpj_cpf = '"+ALLTRIM(TRF1->F1_CGC)+"') "
	cTRERAT+= "     and (tod.cod_empresa = '"+Alltrim(Str(TRF1->EMPRESA))+"') "
	cTRERAT+= "     group by 1,2 "
	conout('cTRERAT')
	conout(cTRERAT)

	//If !Empty(ALLTRIM(TRF1->F1_MLID))	 
     //  cTRERAT+= "     and m.mlid = '"+ALLTRIM(TRF1->F1_MLID)+"' "
    //EndIf
   // cTRERAT+= "   group by D1_CC,E2_NUM "

	
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
	conout(cQuery)
	If (Select ("QRCC")<> 0)
		QRCC->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QRCC"

	DbSelectArea("QRCC")
	While !EOF()
		cRet := Alltrim(QRCC->ZZ9_CAMP2)
		QRCC->(DbSkip())
	EndDo

	QRCC->(DbCloseArea())
	
	RestArea(aAreaCC)  
	
Return cRet

//Realiza a Baixa do título
Static Function BaixarTit()	
	
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

	//Volta parâmetro para seu estado original 
	If nBkpMV_PAR > 0 
		MV_PAR01 := nBkpMV_PAR
		__SaveParam("FIN080", aPergAux)
	Endif

	Restarea(_aAreaSm0)	
	Pergunte('SLAAGR10',.F.)

Return()

//Provisório utilizado para casas de duplicidade por causa da série
User function SLAAGR1X()

	Local cQuery := ""

	cQuery := " SELECT E2_SALDO,E2_FILORIG,E2_PREFIXO,F1_SERIE, E2_BAIXA,E2_SALDO ,F1_DTDIGIT,F1.R_E_C_N_O_,* FROM SF1200(NOLOCK) F1 "
	cQuery += " LEFT JOIN SE2200 ON E2_NUM = F1_DOC AND E2_FORNECE = F1_FORNECE AND E2_LOJA = F1_LOJA  AND F1_PREFIXO = E2_PREFIXO "
	cQuery += " WHERE F1_SERIE LIKE '%00%' AND F1_FILIAL+F1_DOC+F1_FORNECE+F1_LOJA+CONVERT(VARCHAR, F1_EMISSAO )  IN( "
	//--TODAS DA EMPRESA 20 COM SERIE 00 com inclusão no mês 12 
	cQuery += " SELECT F1_FILIAL+F1_DOC+F1_FORNECE+F1_LOJA+CONVERT(VARCHAR, F1_EMISSAO ) FROM SF1200(NOLOCK) "
	cQuery += " WHERE F1_EMISSAO >= '20201101' "
	cQuery += " AND F1_SERIE LIKE '00%' "
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " and CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(F1_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(F1_USERLGI,16,1)) - 50)),'19960101'),112) "
	cQuery += " >= '20201201' "
	cQuery += " INTERSECT "
	//--TODAS DA EMPRESA 20 COM SERIE 00 com inclusão no mês 11
	cQuery += " SELECT F1_FILIAL+F1_DOC+F1_FORNECE+F1_LOJA+CONVERT(VARCHAR, F1_EMISSAO ) FROM SF1200 (NOLOCK) "
	cQuery += " WHERE F1_EMISSAO >= '20201101' "
	cQuery += " AND F1_SERIE NOT LIKE '00%' "
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += "	) "
	conout(cQuery)

	If Select("QRYSF1") <> 0
		dbSelectArea("QRYSF1")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "QRYSF1"


	While QRYSF1->(!eof())

		
		dbselectarea('SF1')
		Dbgoto(QRYSF1->R_E_C_N_O_)	

		conout('NOTA: '+SF1->F1_DOC)
		cQuery := " UPDATE " + RETSQLNAME("SD1") + " SET "
		cQuery += "        D_E_L_E_T_   = '*', "
		cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
		cQuery += " WHERE "
		cQuery += "   D1_DOC    	  =  '" + SF1->F1_DOC + "' "
		cQuery += "   AND D1_SERIE    =  '" +SF1->F1_SERIE+"' "
		cQuery += "   AND D1_FORNECE  =  '" + SF1->F1_FORNECE + "' "
		cQuery += "   AND D1_LOJA     =  '" + SF1->F1_LOJA + "' " 
		cQuery += "   AND D1_FILIAL   =  '" + SF1->F1_FILIAL + "' "
		cQuery += "   AND D_E_L_E_T_  <> '*'  "  

		conout(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SD1: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf           
		
		//Exclui tabelas de Rateio
		cQuery := " UPDATE " + RETSQLNAME("SDE") + " SET "
		cQuery += "        D_E_L_E_T_   = '*', "
		cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
		cQuery += " WHERE "
		cQuery += "   DE_DOC     =  '" + SF1->F1_DOC + "' "
		cQuery += "   AND DE_SERIE     =  '"+SF1->F1_SERIE+"' "
		cQuery += "   AND DE_FORNECE  =  '" + SF1->F1_FORNECE + "' "
		cQuery += "   AND DE_LOJA     =  '" + SF1->F1_LOJA + "' " 
		cQuery += "   AND DE_FILIAL   =  '" + SF1->F1_FILIAL + "' "
		cQuery += "   AND D_E_L_E_T_  <> '*'  "  
			conout(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SDE: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf                                        
																								
		cQuery := " UPDATE " + RETSQLNAME("SF3") + " SET "
		cQuery += "        D_E_L_E_T_   = '*' "
	//	cQuery += "        ,R_E_C_D_E_L_ = R_E_C_N_O_ " 
		cQuery += "  WHERE F3_FILIAL   = '" + SF1->F1_FILIAL + "' "
		cQuery += "    AND F3_NFISCAL  = '" + SF1->F1_DOC    + "' "
		cQuery += "    AND F3_SERIE    = '" + SF1->F1_SERIE + "' "
		cQuery += "    AND F3_CLIEFOR  = '" + SF1->F1_FORNECE  + "' "
		cQuery += "    AND F3_LOJA     = '" + SF1->F1_LOJA      + "' "
	//	cQuery += "    AND F3_ESPECIE  = '"	+SF1->F1_ESPECIE+"' "  
	    conout(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SF3: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf       
		
		
		cQuery := " UPDATE " + RETSQLNAME("SFT") + " SET "
		cQuery += "        D_E_L_E_T_   = '*', "
		cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
		cQuery += "  WHERE FT_FILIAL   = '" +SF1->F1_FILIAL + "' "
		cQuery += "    AND FT_NFISCAL  = '" + SF1->F1_DOC     + "' "
		cQuery += "    AND FT_SERIE    = '" + SF1->F1_SERIE + "' "
		cQuery += "    AND FT_CLIEFOR  = '" +  SF1->F1_FORNECE  + "' "
		cQuery += "    AND FT_LOJA     = '" + SF1->F1_LOJA      + "' "
		cQuery += "    AND FT_ESPECIE  = '"	+SF1->F1_ESPECIE+"' "   
	   		conout(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SFT: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf  
					
		cQuery := " UPDATE " + RETSQLNAME("SF1") + " SET "
		cQuery += "        D_E_L_E_T_   = '*', "
		cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
		cQuery += " WHERE "
		cQuery += "   F1_DOC     =  '" + SF1->F1_DOC + "' "
		cQuery += "   AND F1_SERIE     =  '"+SF1->F1_SERIE+"' "
		cQuery += "   AND F1_FORNECE  =  '" + SF1->F1_FORNECE + "' "
		cQuery += "   AND F1_LOJA     =  '" + SF1->F1_LOJA + "' " 
		cQuery += "   AND F1_FILIAL   =  '" + SF1->F1_FILIAL + "' " 
		cQuery += "   AND D_E_L_E_T_  <> '*'  "   
		conout(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SF1: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf   
		

		cQuery := " UPDATE " + RETSQLNAME("SE2") + " SET "
		cQuery += "        D_E_L_E_T_   = '*', "
		cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
		cQuery += " WHERE E2_PREFIXO  =  '" +SF1->F1_PREFIXO + "' "
		cQuery += "   AND (E2_NUM     =  '" + SF1->F1_DOC + "') "
		//	cQuery += "   AND E2_TIPO     =  'NF' "
		cQuery += "   AND E2_FORNECE  =  '" + SF1->F1_FORNECE + "' "
		cQuery += "   AND E2_LOJA     =  '" + SF1->F1_LOJA + "' "
		cQuery += "   AND D_E_L_E_T_  <> '*'  "	 
		conout(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SE2: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf 
	
		QRYSF1->(DbSkip())
	Enddo 



Return 

//Grava Cte, Foi necessária essa alteração devido ao Emsys nao ter
//tabela de itens para CTE
Static Function GravaCte(xCgc)
	
	Local _cProd := '490019         '

	cDocumento:= PADL(alltrim(TRF1->F1_DOC),9,'0')
	cStatus := 'A'

	DbSelectarea('SB1')
	DbSetOrder(1)
	Dbseek(xfilial('SB1') + _cProd )

	DbSelectArea("SA2")
	DbSetOrder(3)
	If DbSeek(xFilial("SA2")+xCgc)
		cCodFor := SA2->A2_COD
		cLojaFor:= SA2->A2_LOJA
		cNomeFor:= SA2->A2_NOME
	EndIf

	DbSelectArea("SD1")
	
	cNumSeq := GETMV("MV_DOCSEQ")
	cNumSeq := SOMA1(cNumSeq)
	IF GETMV("MV_DOCSEQ") < cNumSeq
		PUTMV("MV_DOCSEQ", cNumSeq)
	ENDIF

	Begin Transaction
		
	Reclock("SD1",.T.)
	
		SD1->D1_FILIAL  := _cXFilial
		SD1->D1_ITEM    := '0001'//cValToChar(StrZero(TRD1->D1_ITEM,4)) //cValToChar(TRD1->D1_ITEM) /* cValToChar(nItem) */
		SD1->D1_COD		:= Alltrim(_cProd)
		SD1->D1_UM      := SB1->B1_UM
		SD1->D1_LOCAL   := SB1->B1_LOCPAD
		SD1->D1_CONTA   := SB1->B1_CONTA
		SD1->D1_TES     := IIF(!Empty(SB1->B1_TE),SB1->B1_TE,'062') //cTES
		SD1->D1_CLASFIS := '000'
		SD1->D1_TP      := SB1->B1_TIPO
		SD1->D1_DESCRI  := SB1->B1_DESC//TRD1->DESCRICAO
		SD1->D1_QUANT   := 1 //TRD1->D1_QUANT
		SD1->D1_VUNIT   := TRF1->F1_VALMERC//TRD1->D1_VUNIT
		SD1->D1_TOTAL   := TRF1->F1_VALMERC//TRD1->D1_TOTAL
		SD1->D1_CUSTO   := TRF1->F1_VALMERC//TRD1->D1_TOTAL
		SD1->D1_VALDESC	:= TRF1->F1_DESCONT//cValDesconto //TRD1->D1_VALDESC
		SD1->D1_FORNECE := cCodFor
		SD1->D1_LOJA    := cLojaFor
		SD1->D1_GRUPO   := SB1->B1_GRUPO//cGrupoD1
		SD1->D1_ITEMCTA := _cXFilial//"01"
		SD1->D1_DOC     := cDocumento//Alltrim(TRF1->F1_DOC)
		SD1->D1_EMISSAO := TRF1->F1_EMISSAO //cDtEmissao//TRD1->D1_EMISSAO
		SD1->D1_DTDIGIT := TRF1->F1_DTDIGIT //cDtDigit  //TRD1->D1_EMISSAO
		SD1->D1_SERIE   := Alltrim(cValToChar(TRF1->F1_SERIE))
		SD1->D1_NUMSEQ  := cNumSeq //SD1->D1_NUMSEQ  := ProxNum() // GETMV("MV_DOCSEQ")
		SD1->D1_TIPO    := "N"//TRD1->D1_TIPN //"N"
		SD1->D1_ORIIMP  := "SLAARG1A"
		SD1->D1_CF      := TRF1->F1_CFO//TRD1->D1_CF
		iF TRF1->F1_BASEICM > 0 
			SD1->D1_BASEICM := TRF1->F1_BASEICM//TRD1->D1_BASEICM
			SD1->D1_VALICM  := TRF1->F1_VALICM 
			SD1->D1_PICM    := Round( (( TRF1->F1_VALICM /TRF1->F1_BASEICM) * 100),2 )	
		Endif 
		/* incluido */
		SD1->D1_DESC    := TRF1->F1_DESCONT//TRD1->D1_DESC
		SD1->D1_SEGURO  := TRF1->valor_seguro//TRD1->D1_SEGURO
		SD1->D1_VALFRE  := 0//TRD1->D1_VALFRE
		SD1->D1_DESPESA := TRF1->F1_DESPESA
		SD1->D1_RATEIO  := "2"//cD1_RATEIO//"2"
		
		// Caso o Centro de Custo esteja VAZIO, 
		// deverá pegar do padrão da filial
		// Quando utilizado Contas 	
		cCtaDeb := U_AGR120() //Chama a Função que preenche a Conta no LP
		//If substr(ALLTRIM(cCtaDeb),1,2) >= '52'
			SD1->D1_CC  := GetCCPadra(_cXFilial)
		//Endif
	SD1->(MsUnlock())
	End Transaction	

Return 

Static function DadosDuCTE()

	Local cTRE2 := ""

	cTRE2 := "select "+chr(13)
    cTRE2 += "case when tnfe.seq_movimento_caixa is null then 0  else 405 end as CODNAT, "  +chr(13) 
    cTRE2 += "tnfe.num_conhecimento as E2_NUM,    "      +chr(13)
    cTRE2 += "tnfe.cod_pessoa_transportadora as codigo, "+chr(13)
    cTRE2 += "tnfe.cod_empresa as codigo,  "+chr(13)
    cTRE2 += " tnfe.dta_emissao as E2_EMISSAO,     " +chr(13)   
    cTRE2 += "coalesce(tpn.seq_titulo_pagar,0) as E2_PARCELA,   "+chr(13)
    cTRE2 += "case when tpn.dta_vencimento is null then tnfe.dta_entrada else tpn.dta_vencimento end as E2_VENCTO,  "   +chr(13)     
    cTRE2 += "case when (coalesce(tpn.val_parcela,0) = 0) then tnfe.val_total_frete else tpn.val_parcela end as E2_VALOR,    "     +chr(13)
    cTRE2 += "tno.des_natureza_operacao as E2_HIST,     " +chr(13)    
    cTRE2 += "tp.num_cnpj_cpf as E2_CNPJ,    "   +chr(13)  
    cTRE2 += "tnfe.cod_empresa as empresa,   "    +chr(13) 
    cTRE2 += "'' as D1_CC      "     		+chr(13)								
    cTRE2 += " from tab_conhecimento tnfe      "    +chr(13)   													   
    cTRE2 += "inner join tab_natureza_operacao tno on (tno.cod_natureza_operacao = tnfe.cod_natureza_operacao)   "   +chr(13)   
    cTRE2 += "inner join tab_pessoa tp on (tp.cod_pessoa = tnfe.cod_pessoa_transportadora)   "    +chr(13)   
    cTRE2 += " left  join tab_parcela_conhecimento tpn on (tpn.seq_conhecimento = tnfe.seq_conhecimento)  "+chr(13)
    cTRE2 += "where tno.ind_gera_financeiro  = 'S' "+chr(13)																						  
    cTRE2+= "    and  tnfe.num_conhecimento  = '"+ALLTRIM(TRF1->F1_DOC)+"'" +chr(13)//-- /* nota_fiscal.numero_nota */
    cTRE2+= "    and ((tp.num_cnpj_cpf = '"+ALLTRIM(TRF1->F1_CGC)+"' ))" +chr(13)
    cTRE2+= "    and tnfe.cod_empresa = '"+Alltrim(Str(TRF1->EMPRESA))+"' " +chr(13)
    
	If !Empty(ALLTRIM(TRF1->F1_MLID))
       cTRE2+= "         and tnfe.seq_conhecimento = '"+ALLTRIM(TRF1->F1_MLID)+"' "+chr(13)
    EndIf
    
	cTRE2+= "         order by tpn.dta_vencimento "+chr(13)

	conout('cTRE2')
	conout(cTRE2)
	If Select("TRE2") > 0
		TRE2->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRE2), "TRE2", .F., .T.)

Return()


User Function SLAAGR1L()

	Local cQuery     := ""
	Local cProdutos  := ""
	Local cTRB1      := ""
	Private oXagCon  := XAGConexao():New()
	Private cProduto := ""//TRD1->D1_PRODUTO
	Private lProduto := .T.
	//Busco Todas os produtos que Precisam ser cadastrados 
	cQuery += " SELECT DISTINCT(D1_COD) FROM SD1200(NOLOCK) D1 "
	cQuery += " LEFT JOIN SB1200(NOLOCK) B1 ON B1_COD = D1_COD "//AND B1_FILIAL = D1_FILIAL "
	cQuery += " AND B1.D_E_L_E_T_ = '' "
	cQuery += " WHERE D1_ORIIMP = 'SLAARG1A  ' "
	cQuery += " AND D1.D_E_L_E_T_ = '' AND B1_COD IS NULL "
	//cQuery += " AND D1_COD NOT LIKE '%E%' "
	//cQuery += " AND D1_COD NOT LIKE '%A%' "
	//cQuery += " AND D1_COD NOT LIKE  '%C%' "
	cQuery += " ORDER BY D1_COD "
	
	If (Select ("AGR1L")<> 0)
		AGR1L->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "AGR1L"

	While AGR1L->(!eof())

		cProdutos += "'"+AGR1L->D1_COD+"'"	
		AGR1L->(dbskip())
		If AGR1L->(!eof())
			cProdutos += ','
		Endif 
	Enddo

	//Busca Dados do Produto 
	oXagCon:ConecEMS()
	cTRB1:=  " select distinct cast(ti.cod_item  AS varchar(15)) as B1_PRODUTO, " 
    cTRB1+=  " ti.des_item as B1_DESC, "
    cTRB1+=  " ti.ind_tipo_item as B1_TIPO, " 
    cTRB1+=  " tgi.cod_grupo_item as B1_GRUPO, "
    cTRB1+=  " tu.sgl_unidade as B1_UM, "
    cTRB1+=  " tgi.des_grupo_item as B1_NOMEG,"
    cTRB1+=  " tn.cod_ncm as B1_POSIPI,"
    cTRB1+=  " ti.cod_item as B1_GRID,"
    cTRB1+=  " tcce.des_classificacao as B1_CONTA,"
    cTRB1+=  " tn.cod_cest as B1_CEST"
    cTRB1+=  " from tab_item ti"
    cTRB1+=  " inner join tab_subgrupo_item tsi on (tsi.cod_subgrupo_item = ti.cod_subgrupo_item)"
    cTRB1+=  " inner join tab_grupo_item tgi on (tgi.cod_grupo_item = tsi.cod_grupo_item)"
    cTRB1+=  " inner join tab_unidade tu on (tu.cod_unidade = ti.cod_unidade)"
    cTRB1+=  " left join tab_ncm tn on (tn.seq_ncm = ti.seq_ncm)"
    cTRB1+=  " left join tab_item_empresa tie on (tie.cod_item = ti.cod_item)"
    cTRB1+=  " left join tab_ctb_conta_empresa tcce on (tcce.seq_conta = tie.seq_conta) "
    cTRB1+=  " where ti.cod_item in (" + cProdutos + ") "
	
	
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cTRB1), "TRB1", .F., .T.)

	oXagCon:ConecPRT()
	while TRB1->(!Eof())
	cProduto := TRB1->B1_PRODUTO
		//Grava dados do Produto
		GravProd() 
		
		TRB1->(dbskip())	
	enddo


Return

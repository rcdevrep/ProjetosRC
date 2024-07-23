#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"

//---------------------------------------+
// Data : 08/02/2016  Autor: Layze Ribas |
//---------------------------------------+
// Descrição: Integração de Notas de     |
// Saída Protheus x AutoSystem           |
//---------------------------------------+

User Function SLAAGR11()

	Private	cCadastro := "Redução. Z"

	Private  aRotina   := { { "Importar" ,"U_SLA11_IMP()" , 0, 1},;
	{ "Legenda"  ,"U_SLA11_LEG()" , 0, 3}}
	aCores := {{"VENDLIQ = VENDLIQ2 .AND. ALLTRIM(NOME)<> '' ",'BR_VERDE'    } ,;
	{"VENDLIQ <> VENDLIQ2",'BR_VERMELHO'   },;
	{"ALLTRIM(NOME) = ''      ",'BR_LARANJA'   }}
	Private aTam := {}
	Private _cNome    := StrTran(DTOC(Date()),"/","_")+"-"+StrTran(time(),":","")
	Private nHandle   := FCREATE("log_autosystem\SLAAGR11_"+_cNome+".txt")

	If nHandle = -1
		Conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	Else
		FWrite(nHandle, Time() + CRLF)
	Endif

	If cEmpAnt <> '20'.AND.cEmpAnt <> '13'.AND.cEmpAnt <> '17'.AND.cEmpAnt <> '21'.AND.cEmpAnt <> '24'.AND.cEmpAnt <> '25'.AND.cEmpAnt <> '27'.AND. cEmpAnt <> '44' .AND. cEmpAnt <> '51'.AND.cEmpAnt <> '52'.AND.cEmpAnt <> '53'.AND.cEmpAnt <> '57'
		Alert("Atenção! Esta rotina está disponivel somente para as Empresas 13, 17, 20, 21, 24, 25, 27, 44, 51, 52, 53, 57!")
		Return()
	EndIf

	cPerg := "SLAAGR11"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Data de            ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Data até           ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Cupons             ?","mv_ch3","N",01,0,0,"C","","mv_par03","Todos","","","Somente Divergencias","","","Aptos a Importar","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Cupom de           ?","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Cupom ate          ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","PDV de             ?","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","PDV ate            ?","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Filial de          ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Filial ate         ?","mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Cupons Eletronicos ?","mv_ch0","N",01,0,0,"C","","mv_par10","Nao","","","Sim","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	aCamp1 := {}
	//aTam    := {}
	cArqTrab1 := ""

	AADD(aCamp1,{"CODFIL"    ,"C",2,0 } )
	AADD(aCamp1,{"FILIAL"    ,"C",15,0 } )
	AADD(aCamp1,{"CGC"       ,"C",15,0 } )
	AADD(aCamp1,{"UF"        ,"C",2,0 } )

	cArqTrab1:= CriaTrab(aCamp1,.T.)

	If Select("EMP") <> 0
		dbSelectArea("EMP")
		dbCloseArea()
	Endif

	dbUseArea(.T.,,cArqTrab1,"EMP",.T.,.F.)
	Indregua("EMP",cArqTrab1,"CGC",,,OemToAnsi("Selecionando Registros..."))

	DbSelectArea("SM0")
	DbGoTop()
	While SM0->(!Eof())
		If SM0->M0_CODIGO == cEmpAnt
			RecLock("EMP",.T.)
			EMP->CODFIL := SM0->M0_CODFIL
			EMP->FILIAL := SM0->M0_FILIAL
			EMP->CGC    := SM0->M0_CGC
			EMP->UF     := SM0->M0_ESTCOB
			MsUnLock()
		EndIf
		SM0->(DbSkip())
	End Do                                                                                                      .

	aCampos := {}
	aTam    := {}
	cArqTrab := ""

	aTam:=TamSX3("A1_LOJA")
	AADD(aCampos,{"LOJA"       ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("A1_NREDUZ")
	AADD(aCampos,{"NOME"       ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_DOC")
	AADD(aCampos,{"CUPOM"        ,"C",aTam[1],aTam[2]} )

	aTam:=TamSX3("D2_SERIE")
	AADD(aCampos,{"PDV"      ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_EMISSAO")
	AADD(aCampos,{"DATACUP"    ,"D",8,0} )

	aTam:=TamSX3("D2_QUANT")
	AADD(aCampos,{"QUANT"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9901"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9902"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9903"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9904"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9905"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9906"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9907"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9908"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9909"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9910"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9911"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VLR9929"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VENDLIQ"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCampos,{"VENDLIQ2"    ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("A1_CGC")
	AADD(aCampos,{"CGC"    ,"C",15,0 } )

	aTam:=TamSX3("A1_EST")
	AADD(aCampos,{"UF"    ,"C",2,0 } )

	cArqTrab:= CriaTrab(aCampos,.T.)

	If Select("SLA02") <> 0
		dbSelectArea("SLA02")
		dbCloseArea()
	Endif

	dbUseArea(.T.,,cArqTrab,"SLA02",.T.,.F.)
	Indregua("SLA02",cArqTrab,"CUPOM",,,OemToAnsi("Selecionando Registros..."))

	Processa({|| BUSCATKE()}, "Buscando Info. Autosystem,Aguarde...")

	//CriaBrow()

	aCamposBrw:= {}

	aTam:=TamSX3("D2_EMISSAO")
	AADD(aCamposBrw,{"Data", "DATACUP", "D",8,0, "" } )

	aTam:=TamSX3("D2_DOC")
	AADD(aCamposBrw,{"Cupom", "CUPOM", "C",aTam[1],aTam[2], "" } )

	aTam:=TamSX3("D2_SERIE")
	AADD(aCamposBrw,{"PDV", "PDV", "C",aTam[1],aTam[2],"" } )

	aTam:=TamSX3("A1_LOJA")
	AADD(aCamposBrw,{"Loja", "LOJA","C",aTam[1],aTam[2], "" } )

	aTam:=TamSX3("A1_NREDUZ")
	AADD(aCamposBrw,{"Razao Social", "NOME","C",aTam[1],aTam[2], "" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Mapa Resumo", "VENDLIQ","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Vendas PDV", "VENDLIQ2","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Alíquota 7%", "VLR9901","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Alíquota 12%", "VLR9902","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Aliquota 17%", "VLR9903","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Alíquota 25%", "VLR9904","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Isentas", "VLR9905","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Dif. Substit. Tribuaria", "VLR9906","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Cigarros", "VLR9907","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Combustiveis", "VLR9908","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Lubrificantes", "VLR9909","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Gas Natural", "VLR9910","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Serviço de Lavação", "VLR9911","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("D2_PRCVEN")
	AADD(aCamposBrw,{"Alíquota 18%", "VLR9929","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

	aTam:=TamSX3("A1_CGC")
	AADD(aCamposBrw,{"CNPJ", "CGC","C",15,0, "@R 99.999.999/9999-99" } )

	dbSelectArea("SLA02")
	dbSetOrder(1)
	mBrowse(,,,,"SLA02",aCamposBrw,,,,,aCores)

Return NIL

//------------------------------------------+
// FUNÇÃO PARA CONEXÃO                      |
//------------------------------------------+
Static Function BUSCATKE()

	Local cQuery      := ""
	Local lRet        := .t.
	Private oXagCon   := XAGConexao():New()

	If (!oXagCon:ConecATS())
		CONOUT("Não foi possivel conectar ao Autosystem ...","ERROR","ERROR")
		FWrite(nHandle, "SLAARG11 - Não foi possivel conectar ao Autosystem." + CRLF)
		RETURN
	EndIf

	FWrite(nHandle, "SLAARG11  - Conexão com o servidor estabelecida." + CRLF)

	/*
	* foi separado em uma variavel de pergunta para entregar a solucao o quanto antes,
	* quando for trabalhar com integracao automatizada, tem que refazer a estrutura que
	* faz a carga dos dados do AutoSystem, pois os sqls que estao divididos nas clausulas
	* devem funcionar com union all.
	* Em pien saiu cupom com serie 8 ate 25/08/16, apos saiu serie 2. Esta fixo para serie 98 e 99
	*/
	if (mv_par10 == 2)

		cQuery:= "select "
		cQuery+= "       sum((CASE WHEN nfp.aliquota_icms='7'  and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END)) as VLR9901, "
		cQuery+= "       sum((CASE WHEN nfp.aliquota_icms='12' and nfp.cst not in ('060','062') and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END)) as VLR9902, "
		cQuery+= "       sum((CASE WHEN nfp.aliquota_icms='17' and nfp.cst not in ('065') and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END)) as VLR9903, "
		cQuery+= "       sum((CASE WHEN nfp.aliquota_icms='18' and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END)) as VLR9929, "
		cQuery+= "       sum((CASE WHEN nfp.aliquota_icms='25' and nfp.cst in ('000') and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END)) as VLR9904, "
		cQuery+= "       sum((CASE WHEN gp.codigo=13           and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END)) as VLR9905, "
		cQuery+= "       sum((CASE WHEN nfp.aliquota_icms >='2' and nfp.aliquota_icms <='5' and nfts.nome = 'APROVADA' THEN trunc((nfp.valor)::numeric, 2) ELSE 0 END)) as VLR9911, "
		cQuery+= "       sum((CASE WHEN gp.codigo=1  and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END))     as VLR9907, "
		cQuery+= "       sum((CASE WHEN gp.codigo in (18) and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END)) as VLR9908, "
		cQuery+= "       sum((CASE WHEN gp.codigo in (22) and nfp.aliquota_icms='0' and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END)) as VLR9909, "
		cQuery+= "       sum((CASE WHEN gp.codigo=20 and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END))     as VLR9910, "
		cQuery+= "       sum((CASE WHEN true  and nfts.nome = 'APROVADA' THEN ((nfp.valor - nfp.valor_desconto + nfp.valor_acrescimo)::numeric) ELSE 0 END))            as VLR9906, "
		cQuery+= "       cast(null as varchar(30)) as nr_serie, cast(e.cpf as varchar(20)) CNPJ, cast(case when nf.data_emissao < '20160826' then 99 else 98 end as varchar(50)) as SERIE, "
		cQuery+= "       nf.empresa,                            nf.data_emissao as data_movto,      null as empresa,                                                                       "
		cQuery+= "       case when nf.data_emissao < '20160826' then 99 else 98 end AS PDV,         null as hora_emissao,  nf.data_emissao AS DATACUP, cast(max(documento) as varchar(9)) AS CUPOM,  "
		cQuery+= "       null as cupom_ini,                     null as cupom_fim,                  null as cont_reinicio,                   null as cont_reducao, null as cont_cancela,   "
		cQuery+= "       null as cancelamento,                  null as desconto,                   null as acrescimo,                       null as isencao,      null as nao_incide,     "
		cQuery+= "       null as substituicao,                  null as sangria,                    null as suprimento,                      null as grade_total,  null as venda_bruta,    "
		cQuery+= "       null as cancelamento_iss,              null as desconto_iss,               null as acrescimo_iss,                   null as isencao_iss,  null as nao_incide_iss, "
		cQuery+= "       null as substituicao_iss,              sum((l.valor)::numeric) as VENDLIQ, null as versao_firmware,                 null as ts_firmware                           "
		cQuery+= "  from nota_fiscal nf "
		cQuery+= "       join nota_fiscal_produto nfp  on (nfp.nota_fiscal = nf.grid) "
		cQuery+= "       join produto p                on (p.grid = nfp.produto) "
		cQuery+= "       join grupo_produto gp         on (gp.grid=p.grupo) "
		cQuery+= "       join empresa e                on (e.grid = nf.empresa) "
		cQuery+= "       join nota_fiscal_situacao nfs on (nf.grid = nfs.nota_fiscal) "
		cQuery+= "       left join nota_fiscal_tipo_situacao nfts on (nfs.situacao = nfts.codigo) "
		cQuery+= "       left join nota_fiscal_pessoa np on (np.grid=(case when (substr(nfp.cfop,1,1)::int not in (1,2,3)) then nf.destinatario else nf.emitente end)) "
		cQuery+= "       join lancto l on (l.grid = nfp.lancto) "
		cQuery+= " where nf.tipo     = 'S' "
		cQuery+= "   and nf.situacao = 'E' "
		cQuery+= "   and nf.empresa in (6814808,6816193) " // colocado filtro para somente filial de PIEN
		cQuery+= "   and nf.data_emissao between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' "
		//cQuery+= "   and coalesce(lpad(nf.modelo_doc::text,2,'0'),'01') in ('01','1B','02','04','55','06','21','22','07','08','09','10','11','26','27','28','29','57', '59', '65', '99') "
		cQuery+= "   and coalesce(lpad(nf.modelo_doc::text,2,'0'),'01') in ('65') "
		cQuery+= "   and nfp.cfop in ('5.102','6.102','5.405','6.405','5.403','6.403','6.656','5.667','5.656') "
		If Empty(Alltrim(mv_par04))
			cQuery+= " and documento between '000001' and '999999' "
		ELSE
			cQuery+= " and documento Between '"+alltrim(mv_par04)+"' and '"+alltrim(mv_par05)+"'  "
		EndIf
		cQuery+= " group by e.cpf, nf.empresa, nf.data_emissao, l.conta, l.data "

	ELSE
		//cQuery+= " UNION ALL "

		cQuery:= " select sum((CASE WHEN cp.aliquota='7'  THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9901, "
		cQuery+= "        sum((CASE WHEN cp.aliquota='12' and cp.tributacao not in ('060','062') THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9902, "
		cQuery+= "        sum((CASE WHEN cp.aliquota='17' and cp.tributacao not in ('065') THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9903, "
		cQuery+= "        sum((CASE WHEN cp.aliquota='18' THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9929, "
		cQuery+= "        sum((CASE WHEN cp.aliquota='25' and cp.tributacao not in ('061') and gp.codigo not in (18) THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9904, "
		cQuery+= "        sum((CASE WHEN gp.codigo=13     THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9905, "
		//cQuery+= "        sum((CASE WHEN gp.codigo=2      THEN trunc((cp.quantidade*cp.preco_unit)::numeric, 2) ELSE 0 END)) as VLR9911, "
		cQuery+= "        sum((CASE WHEN cp.aliquota >='2' and cp.aliquota <='5' THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9911, "
		cQuery+= "        sum((CASE WHEN gp.codigo=1       THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9907, "
		cQuery+= "        sum((CASE WHEN gp.codigo in (18) THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9908, "
		cQuery+= "        sum((CASE WHEN gp.codigo in (22) THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9909, "
		cQuery+= "        sum((CASE WHEN gp.codigo=20      THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9910, "
		cQuery+= "        sum((CASE WHEN true              THEN trunc((l.valor)::numeric, 2) ELSE 0 END)) as VLR9906, "
		cQuery+= "        cast(c.nr_serie as varchar(30)) as nr_serie,    cast(e.cpf as varchar(20)) CNPJ,  cast(rz.nr_serie as varchar(50)) SERIE,"
		cQuery+= "        c.empresa,             c.data_movto,    rz.empresa,         rz.nr_ecf AS PDV,    rz.hora_emissao,     rz.data_movto AS DATACUP, "
		cQuery+= "        cast(rz.nr_cupom as varchar(9)) AS CUPOM,  rz.cupom_ini,    rz.cupom_fim,       rz.cont_reinicio,    rz.cont_reducao,     rz.cont_cancela, "
		cQuery+= "        rz.cancelamento,       rz.desconto,     rz.acrescimo,       rz.isencao,          rz.nao_incide,       rz.substituicao, "
		cQuery+= "        rz.sangria,            rz.suprimento,   rz.grande_total,    rz.venda_bruta,      rz.cancelamento_iss, rz.desconto_iss, "
		cQuery+= "        rz.acrescimo_iss,      rz.isencao_iss,  rz.nao_incide_iss,  rz.substituicao_iss,  "
		cQuery+= "        (rz.venda_bruta - rz.cancelamento - rz.desconto + rz.acrescimo) as VENDLIQ ,"
		cQuery+= "        cast(rz.versao_firmware as varchar(10)) as versao_firmware, cast(rz.ts_firmware as varchar(50)) as ts_firmware"
		cQuery+= "   from cupom c "
		cQuery+= "   join cupom_produto cp on (cp.cupom=c.grid) "
		cQuery+= "   join reducao_z rz     on (rz.data_movto=c.data_movto and rz.empresa=c.empresa and rz.nr_serie=c.nr_serie) "
		cQuery+= "   join produto p        on (p.grid=cp.produto)   "
		cQuery+= "   join grupo_produto gp on (gp.grid=p.grupo)    "
		cQuery+= "   join empresa e        on (e.grid=c.empresa)   "
		//cQuery+= "   join lancto l         on (l.produto = p.grid and l.tipo_doc in ('ECF','CUPOM') and l.empresa = c.empresa and l.cupom_produto = cp.grid) " 
		cQuery+= "   join lancto l         on (l.cupom_produto = cp.grid) and l.empresa = c.empresa "		
		cQuery+= "  where l.tipo_doc in ('ECF','CUPOM')"  
		cQuery+= "    and c.data_movto between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' "
		cQuery+= "    and c.situacao='E'  "
		cQuery+= "    and cp.situacao='E' "
		If Empty(Alltrim(mv_par04))
			cQuery+= "   and rz.nr_cupom Between 000001 and 999999  "
		Else
			cQuery+= "   and rz.nr_cupom Between "+alltrim(mv_par04)+" and "+alltrim(mv_par05)+"  "
		EndIf
		If Empty(Alltrim(mv_par06))
			cQuery+= "   and rz.nr_ecf Between 01 and 99  "
		Else
			cQuery+= "   and rz.nr_ecf Between "+alltrim(mv_par06)+" and "+alltrim(mv_par07)+"  "
		EndIf
		cQuery+= " group by c.empresa,     c.data_movto,       c.nr_serie,      rz.empresa,      cast(e.cpf as varchar(20)), cast(rz.nr_serie as varchar(50)),  "
		cQuery+= "       rz.nr_ecf,        rz.hora_emissao,    rz.data_movto,   rz.nr_cupom,     rz.cupom_ini,      rz.cupom_fim,        rz.cont_reinicio, "
		cQuery+= "       rz.cont_reducao,  rz.cont_cancela,    rz.cancelamento, rz.desconto,     rz.acrescimo,      rz.isencao,          rz.nao_incide,"
		cQuery+= "       rz.substituicao,  rz.sangria,         rz.suprimento,   rz.grande_total, rz.venda_bruta,    rz.cancelamento_iss, rz.desconto_iss,"
		cQuery+= "       rz.acrescimo_iss, rz.versao_firmware, rz.ts_firmware,  rz.isencao_iss,  rz.nao_incide_iss, rz.substituicao_iss "
		cQuery+= " order by 21 " //rz.data_movto "
	EndIf

	If Select("QRYTKE") <> 0
		dbSelectArea("QRYTKE")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "QRYTKE"
	//TCSetField("QRYTKE", "DATACUP", "D", 08, 0)

	cCodCli := ""
	cLojCli := ""
	cNomCli := ""
	cUF    := ""
	dbSelectArea("QRYTKE")
	dbGoTop()
	do While !eof()
		cCNPJ := ALLTRIM(QRYTKE->CNPJ)
		cCNPJ := STRTRAN(cCNPJ,".","")
		cCNPJ := STRTRAN(cCNPJ,"-","")
		cCNPJ := STRTRAN(cCNPJ,"/","")

		oXagCon:ConecPRT()

		dbSelectArea("EMP")
		dbGotop()
		dbSeek(cCNPJ)

		cLojCli := EMP->CODFIL
		cNomCli := EMP->FILIAL
		cUF     := EMP->UF

		lImp := .f.

		cFilial1 := ""
		DbSelectArea("SM0")
		SM0->(dbGoTop())
		SM0->(DbSetorder(1))
		Dbseek(cEmpAnt)
		While SM0->(!Eof() ) .AND. cEmpAnt == SM0->M0_CODIGO 
			If alltrim(SM0->M0_CGC) == ALLTRIM(cCNPJ)
				cFilial1 := SM0->M0_CODFIL
			EndIf
			SM0->(DbSkip())
		EndDo

		cCliAux:= ""
		lEcfCup:= .f.
		If cUF == "PR"
			cCliAux := "12020"
		Else
			cCliAux := "008010"
		EndIf

		lEcfCup := .f.

		If cFilial1 >= mv_par08 .and. cFilial1 <= mv_par09 
			lEcfCup := .t.
		Else
			lEcfCup := .F.
		EndIf

		cQry := ""
		cQry := "   SELECT F2_DOC "
		cQry += "   FROM " + RETSQLNAME("SF2") + " (NOLOCK) "
		cQry += "   WHERE F2_FILIAL  = '" + ALLTRIM(cFilial1) +  "' "
		cQry += "     AND F2_CLIENTE = '" + ALLTRIM(cCliAux)  +  "' "
		cQry += "     AND F2_LOJA    = '01' "
		cQry += "     AND F2_SERIE   = '" + ALLTRIM(STR(QRYTKE->PDV)) + "' "

		cQry += "     AND F2_DOC    IN ('" + ALLTRIM(cValTochar(QRYTKE->CUPOM)) + "','"
		cQry +=                         PadL(ALLTRIM(cValTochar(QRYTKE->CUPOM)), TamSX3("F2_DOC")[1], "0") + "')"

		cQry += "     AND D_E_L_E_T_ = ''  "

		If Select("QRY_SF2") <> 0
			dbSelectArea("QRY_SF2")
			dbCloseArea()
		Endif

		TCQuery cQry NEW ALIAS "QRY_SF2"

		dbSelectArea("QRY_SF2")
		QRY_SF2->(dbgotop())
		While QRY_SF2->(!EOF())
			lEcfCup := .F.
			QRY_SF2->(dbSkip())
		EndDo

		If ((mv_par03 == 1 .and. lEcfCup == .T. ) .or. (mv_par03 = 2 .and. (QRYTKE->VENDLIQ <> QRYTKE->VENDLIQ  .OR. ALLTRIM(cNomCli) == "" .and. lEcfCup == .T.) ) ;
		.or. (mv_par03 == 3 .and. (QRYTKE->VENDLIQ  == QRYTKE->VENDLIQ .AND. ALLTRIM(cNomCli) <> "" .and. lEcfCup == .T.) ))
			dbSelectArea("SLA02")
			If cNomCLi == ""
				CONOUT(ALLTRIM(QRYTKE->CNPJ))
			EndIf
			RecLock("SLA02",.T.)
			SLA02->LOJA    := cLojCli
			SLA02->NOME    := cNomCli
			SLA02->CGC     := cCNPJ
			SLA02->CUPOM   := Alltrim(cValToChar(QRYTKE->CUPOM))
			SLA02->PDV     := ALLTRIM(STR(QRYTKE->PDV))
			SLA02->DATACUP := QRYTKE->DATACUP
			SLA02->QUANT   := 1
			SLA02->VLR9901 := QRYTKE->VLR9901
			SLA02->VLR9902 := QRYTKE->VLR9902
			SLA02->VLR9903 := QRYTKE->VLR9903
			SLA02->VLR9904 := QRYTKE->VLR9904
			SLA02->VLR9905 := QRYTKE->VLR9905
			SLA02->VLR9906 := QRYTKE->VLR9906 - (QRYTKE->VLR9901 + QRYTKE->VLR9902 + QRYTKE->VLR9903 + QRYTKE->VLR9904 + QRYTKE->VLR9905 + QRYTKE->VLR9907 + QRYTKE->VLR9908+;
			QRYTKE->VLR9909 + QRYTKE->VLR9910 + QRYTKE->VLR9929 + QRYTKE->VLR9911 )
			SLA02->VLR9907 := QRYTKE->VLR9907
			SLA02->VLR9908 := QRYTKE->VLR9908
			SLA02->VLR9909 := QRYTKE->VLR9909
			SLA02->VLR9910 := QRYTKE->VLR9910
			SLA02->VLR9911 := QRYTKE->VLR9911
			SLA02->VLR9929 := QRYTKE->VLR9929
			SLA02->VENDLIQ := QRYTKE->VENDLIQ
			SLA02->VENDLIQ2 := QRYTKE->VENDLIQ
			SLA02->UF := cUF
			MsUnlock()
		endif
		dbSelectArea("QRYTKE")
		QRYTKE->(dbskip())
	EndDo

	oXagCon:DescATS()

Return()

//------------------------------------------+
// FUNÇÃO PARA CRIAR O BROWSE               |
//------------------------------------------+
/*Static Function CRIABROW()
Private	aCamposBrw := {}

Private  aRotina   := { { "Importar" ,"U_SLA11_IMP()" , 0, 1},;
{ "Legenda"  ,"U_SLA11_LEG()" , 0, 3}}

aCores := {{"VENDLIQ = VENDLIQ2 .AND. ALLTRIM(NOME)<> '' ",'BR_VERDE'    } ,;
{"VENDLIQ <> VENDLIQ2",'BR_VERMELHO'   },;
{"ALLTRIM(NOME) = ''      ",'BR_LARANJA'   }}

Private aTam := {}

AADD(aCamposBrw,{"Data", "DATACUP", "D",8,0, "" } )
AADD(aCamposBrw,{"Cupom", "CUPOM", "C",6,0, "" } )

aTam:=TamSX3("D2_SERIE")
AADD(aCamposBrw,{"PDV", "PDV", "C",6,0, "" } )

aTam:=TamSX3("A1_LOJA")
AADD(aCamposBrw,{"Loja", "LOJA","C",aTam[1],aTam[2], "" } )

aTam:=TamSX3("A1_NREDUZ")
AADD(aCamposBrw,{"Razao Social", "NOME","C",aTam[1],aTam[2], "" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"Mapa Resumo", "VENDLIQ","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"Vendas PDV", "VENDLIQ2","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9901", "VLR9901","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9902", "VLR9902","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9903", "VLR9903","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9904", "VLR9904","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9905", "VLR9905","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9906", "VLR9906","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9907", "VLR9907","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9908", "VLR9908","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9909", "VLR9909","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9910", "VLR9910","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9911", "VLR9911","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("D2_PRCVEN")
AADD(aCamposBrw,{"9929", "VLR9929","N",aTam[1],aTam[2], "@E 999,999,999.99" } )

aTam:=TamSX3("A1_CGC")
AADD(aCamposBrw,{"CNPJ", "CGC","C",15,0, "" } )

dbSelectArea("SLA02")
dbSetOrder(1)
mBrowse(6,1,22,75,"SLA02",aCamposBrw,,,,,aCores)

Return() */

//------------------------------------------+
// FUNÇÃO PARA IMPORTAÇÃO                   |
//------------------------------------------+
User Function SLA11_IMP

	If !msgyesno("Deseja continuar a importação?")
		return()
	else
		Processa({|| Importa()}, "Analisando Fornecedores! Aguarde...")
	EndIF

Return()

Static Function Importa()

	Local aParam  := array(15)
	Local lRotAut := .t.

	dbSelectArea("SLA02")
	dbGoTop()
	ProcRegua(SLA02->(RecCount()))
	do While !eof()
		IncProc("CUPOM: " + SLA02->CUPOM + "       PDV:"  + SLA02->PDV)
		If SLA02->VENDLIQ == SLA02->VENDLIQ2 .AND. ALLTRIM(SLA02->NOME)<> ''
			cFilial1 := ""

			DbSelectArea("SM0")
			dbGoTop()
			While SM0->(!Eof() )
				If alltrim(SM0->M0_CGC) == ALLTRIM(SLA02->CGC)
					cFilial1 := SM0->M0_CODFIL
				EndIf
				SM0->(DbSkip())
			EndDo

			cCliente:= "008010"
			cLoja   := "01"
			FWrite(nHandle, "EMPRESA:"+cEmpAnt+" | FILIAL:"+cFilial1+" "+ CRLF)
			Fwrite(nHandle, "INCLUSAO| CUPOM: "+SLA02->CUPOM+" PDV:"+SLA02->PDV+" " + CRLF)
			If cEmpAnt == "20"
				If SLA02->UF == "PR"
					cCliente := "12020"
				Else
					cCliente := "008010"
				EndIf
			ElseIf cEmpAnt == "13"
				If SLA02->UF == "PR"
					cCliente := "12020"
				Else
					cCliente := "008010"
				EndIf
			ElseIf cEmpAnt == "17"
				If SLA02->UF == "PR"
					cCliente := "12020"
				Else
					cCliente := "008010"
				EndIf
			ElseIf cEmpAnt == "21"
				If SLA02->UF == "PR"
					cCliente := "12020"
				Else
					cCliente := "008010"
				EndIf
			EndIf

			dbSelectArea("SF2")
			dbSetOrder(2)
			If !dbSeek(cFilial1+cCliente+"01"+SLA02->CUPOM+SLA02->PDV)
				aInfoD2 := {}
				nContIt := 0

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9901  <<<<<<<<<<<<<<<<<<<<<
				//	DbSelectArea("SLA02")
				If SLA02->VLR9901 > 0
					nContIt++
					cItem := StrZero(nContIt,2)
					DbSelectArea("SB1")
					DbSetOrder(1)
					If DbSeek(xFilial("SB1")+"9901")
						cCod    := "9901"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9901
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+cTes)
						cCF     :=  SF4->F4_CF

						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS  := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS := SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0

						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9901")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9902  <<<<<<<<<<<<<<<<<<<<<
				//	DbSelectArea("SLA02")
				If SLA02->VLR9902 > 0
					nContIt++
					cItem := strzero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If DbSeek(xFilial("SB1")+"9902")
						cCod    := "9902"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9902
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+cTes)
						cCF      :=  SF4->F4_CF
						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS  := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS := SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0

						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9902")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9903  <<<<<<<<<<<<<<<<<<<<<
				//	DSelectArea("SLA02")
				If SLA02->VLR9903 > 0
					nContIt++
					cItem := StrZero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If dbSeek(xFilial("SB1")+"9903")
						cCod    := "9903"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9903
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+cTes)
						cCF     :=  SF4->F4_CF

						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS  := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS := SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0

						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO //tipo produto
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9903")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9904  <<<<<<<<<<<<<<<<<<<<<
				//	DbSelectArea("SLA02")
				If SLA02->VLR9904 > 0
					nContIt++
					cItem := StrZero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If dbSeek(xFilial("SB1")+"9904")
						cCod    := "9904"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9904
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+cTes)
						cCF :=  SF4->F4_CF

						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS  := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS := SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0

						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						nPICM    := SB1->B1_PICM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9904")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9905  <<<<<<<<<<<<<<<<<<<<<
				//	DbSelectArea("SLA02")
				If SLA02->VLR9905 > 0
					nContIt++
					cItem := StrZero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If dbSeek(xFilial("SB1")+"9905")
						cCod    := "9905"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9905
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						//Busco Informacoes da TES
						dbSelectArea("SF4")
						dbSetOrder(1)
						dbSeek(xFilial("SF4")+cTes)
						cCF :=  SF4->F4_CF

						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS  := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS := SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0

						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9905")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9906  <<<<<<<<<<<<<<<<<<<<<
				//		DbSelectArea("SLA02")
				If SLA02->VLR9906 > 0
					nContIt++
					cItem := StrZero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If dbSeek(xFilial("SB1")+"9906")
						cCod    := "9906"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9906
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+cTes)
						cCF  :=  SF4->F4_CF

						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS:= SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0
						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9906")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9907  <<<<<<<<<<<<<<<<<<<<<
				//		DbSelectArea("SLA02")
				If SLA02->VLR9907 > 0
					nContIt++
					cItem := strzero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If dbSeek(xFilial("SB1")+"9907")
						cCod    := "9907"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9907
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+cTes)
						cCF :=  SF4->F4_CF

						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS  := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS := SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0
						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						nPICM    := SB1->B1_PICM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO //tipo produto
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9907")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9908  <<<<<<<<<<<<<<<<<<<<<
				//	DbSelectArea("SLA02")
				If SLA02->VLR9908 > 0
					nContIt++
					cItem := StrZero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If dbSeek(xFilial("SB1")+"9908")
						cCod    := "9908"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9908
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+cTes)
						cCF :=  SF4->F4_CF

						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS  := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS := SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0
						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9908")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9909  <<<<<<<<<<<<<<<<<<<<<
				//		DbSelectArea("SLA02")
				If SLA02->VLR9909 > 0
					nContIt++
					cItem := strzero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If dbSeek(xFilial("SB1")+"9909")
						cCod    := "9909"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9909
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						dbSelectArea("SF4")
						dbSetOrder(1)
						dbSeek(xFilial("SF4")+cTes)
						cCF :=  SF4->F4_CF

						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS  := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS := SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0
						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO //tipo produto
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9909")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9910  <<<<<<<<<<<<<<<<<<<<<
				//	DbSelectArea("SLA02")
				If SLA02->VLR9910 > 0
					nContIt++
					cItem := StrZero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If dbSeek(xFilial("SB1")+"9910")
						cCod    := "9910"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9910
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						dbSelectArea("SF4")
						dbSetOrder(1)
						dbSeek(xFilial("SF4")+cTes)
						cCF :=  SF4->F4_CF

						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS  := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS := SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0

						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9910")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9911  <<<<<<<<<<<<<<<<<<<<<
				//	DbSelectArea("SLA02")
				If SLA02->VLR9911 > 0
					nContIt++
					cItem := strzero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If dbSeek(xFilial("SB1")+"9911")
						cCod    := "9911"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9911
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						dbSelectArea("SF4")
						dbSetOrder(1)
						dbSeek(xFilial("SF4")+cTes)
						cCF:=  SF4->F4_CF

						nValISS := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS:= SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0

						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM   := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9911")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				//>>>>>>>>>>>>>>>>>>>>>>  PRODUTO 9929  <<<<<<<<<<<<<<<<<<<<<
				//	DbSelectArea("SLA02")
				If SLA02->VLR9929 > 0
					nContIt++
					cItem := strzero(nContIt,2)

					DbSelectArea("SB1")
					DbSetOrder(1)
					If dbSeek(xFilial("SB1")+"9929")
						cCod    := "9929"
						nQuant  := SLA02->QUANT
						nPrcVen := SLA02->VLR9929
						nTotal  := nQuant * nPrcVen
						cTes    := SB1->B1_TS

						DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+cTes)
						cCF :=  SF4->F4_CF

						nValISS  := 0
						nBaseISS := 0
						nAliqISS := 0

						If SB1->B1_ALIQISS > 0 .and. SF4->F4_ISS == "S"
							nBaseISS := nPrcVen
							nValISS  := nPrcVen * (SB1->B1_ALIQISS / 100)
							nAliqISS := SB1->B1_ALIQISS
						EndIf

						nBaseIcm:= 0
						nValIcm := 0
						nPICM   := 0
						If SB1->B1_PICM > 0 .and. SF4->F4_ICM == "S"
							nValIcm  := nPrcVen * (SB1->B1_PICM / 100)
							nBaseIcm := nPrcVen
							nPICM    := SB1->B1_PICM
						EndIf

						cUM      := SB1->B1_UM
						cConta   := SB1->B1_CONTA
						cLocal   := SB1->B1_LOCPAD
						cGrupo   := SB1->B1_GRUPO
						cTP      := SB1->B1_TIPO
						cTipo    := "N"
						cCtaRec  := SB1->B1_CTAREC
						nValBrut := nPrcVen
						cEst     := SLA02->UF
						cNumSeq  := ProxNum()
						dEmissao := SLA02->DATACUP
						cDoc     := SLA02->CUPOM
						cSerie   := SLA02->PDV
					Else
						Alert("Não foi encontrado o produto de código 9929")
					EndIf

					AADD(aInfoD2,{ cFilial1, cItem,cCod,nQuant, nPrcVen,nTotal,cTes, cCF,nValIcm, cUM,nPICM, cConta,cLocal,cGrupo,cTP,cTipo, nBaseIcm,;
					cCtaRec,nValBrut,cEst,cNumSeq,dEmissao, cDoc , cSerie, nValISS , nAliqISS, nBaseISS, cCliente,cLoja })
				EndIf

				nTValBrut := 0
				nTValIcm  := 0
				nTBaseIcm := 0
				nTBaseISS := 0
				nTValISS  := 0
				nTValMerc := 0

				For i:= 1 to Len(aInfoD2)
					RecLock("SD2",.T.)
					SD2->D2_FILIAL  := aInfoD2[i,01]
					SD2->D2_ITEM    := aInfoD2[i,02]
					SD2->D2_COD     := aInfoD2[i,03]
					SD2->D2_QUANT   := aInfoD2[i,04]
					SD2->D2_PRCVEN  := aInfoD2[i,05]
					SD2->D2_TOTAL   := aInfoD2[i,06]
					SD2->D2_TES     := aInfoD2[i,07]
					SD2->D2_CF      := aInfoD2[i,08]
					SD2->D2_VALICM  := aInfoD2[i,09]
					SD2->D2_UM      := aInfoD2[i,10]
					SD2->D2_PICM    := aInfoD2[i,11]
					SD2->D2_CONTA   := aInfoD2[i,12]
					SD2->D2_LOCAL   := aInfoD2[i,13]
					SD2->D2_DOC     := aInfoD2[i,23]
					SD2->D2_EMISSAO := aInfoD2[i,22]
					SD2->D2_GRUPO   := aInfoD2[i,14]
					SD2->D2_TP      := aInfoD2[i,15]
					SD2->D2_SERIE   := aInfoD2[i,24]
					SD2->D2_EST     := aInfoD2[i,20]
					SD2->D2_NUMSEQ  := aInfoD2[i,21]
					SD2->D2_TIPO    := aInfoD2[i,16]
					SD2->D2_BASEICM := aInfoD2[i,17]
					//	       If cEmpAnt == "20"
					SD2->D2_CTAREC  := aInfoD2[i,18]
					//		   EndIf
					SD2->D2_VALBRUT := aInfoD2[i,19]
					SD2->D2_BASEISS := aInfoD2[i,27]
					SD2->D2_ALIQISS := aInfoD2[i,26]
					SD2->D2_VALISS  := aInfoD2[i,25]
					SD2->D2_CLIENTE := aInfoD2[i,28]
					SD2->D2_LOJA    := aInfoD2[i,29]
					nTValBrut       += aInfoD2[i,19]
					nTValIcm        += aInfoD2[i,09]
					nTBaseIcm       += aInfoD2[i,17]
					nTBaseISS       += aInfoD2[i,27]
					nTValISS        += aInfoD2[i,25]
					nTValMerc       += aInfoD2[i,06]
					SD2->(MsUnlock())
				NEXT i

				RecLock("SF2" , .T.)
				SF2->F2_DOC     := SLA02->CUPOM
				SF2->F2_SERIE   := SLA02->PDV
				SF2->F2_EMISSAO := SLA02->DATACUP
				SF2->F2_CLIENTE := cCliente
				SF2->F2_LOJA    := cLoja
				SF2->F2_EST     := SLA02->UF
				SF2->F2_VALBRUT := nTValBrut
				SF2->F2_VALICM  := nTValIcm
				SF2->F2_BASEICM := nTBaseIcm
				SF2->F2_VALMERC := nTValMerc
				SF2->F2_TIPO    := "N"
				//SF2->F2_DTLANC  := SLA02->DATACUP
				SF2->F2_FILIAL  := cFilial1
				SF2->F2_BASEISS := nTBaseISS
				SF2->F2_VALISS  := nTValISS
				SF2->F2_ESPECIE := "CF"
				SF2->F2_MOEDA   := 1
				MsUnLock()
			EndIf
		EndIf
		dbSelectArea("SLA02")
		SLA02->(dbSkip())
	EndDo

	msginfo("Importação Realizada com Sucesso!")
	Fwrite(nHandle, "SLAAGR11 - IMPORTACAO REALIZADA COM SUCESSO." + CRLF)

	closebrowse()
Return()

//------------------------------------------+
// FUNÇÃO PARA LEGENDA                      |
//------------------------------------------+
User Function SLA11_LEG()
	BrwLegenda(cCadastro,"Legenda",    {{"BR_VERDE"      ,"Apto a Importar"    },;
	{"BR_VERMELHO"   ,"Divergência Red.Z X Departamentos" },;
	{"BR_LARANJA"   ,"CNPJ não cadastrado" }})

Return(.T.)
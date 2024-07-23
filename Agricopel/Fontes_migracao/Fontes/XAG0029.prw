#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
Programa.:  XAG0029
Autor....: Emerson - Sla
Data.....: 11/05/2018
Descricao: Rotina para controle de importação dos dados da Folha (Senior)
Uso......: Agricopel
*/

User Function XAG0029()

Local oBrowse
Local lRet			:= .T.
Local aArea			:= GetArea()
Private oProcess  := NIL
Private cCadastro := "XAG0029 - Registro de LOGS  - Importação Folha - Senior"
PRIVATE aRotina:= {{"Pesquisar","AxPesqui",0,1},;
{ "Visualizar" ,"AxVisual" , 0 , 2},;
{ "Importar" 	    		,"u_XAG029J()" , 0 , 3},;
{ "Excluir LOGS"  			,"u_635ZEXC()", 0 , 4}}

If (cEmpAnt == '01' .AND. cFilAnt == '01')
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZDB")
	oBrowse:SetDescription(cCadastro) 			//Descrição do browse
	// Adiciona um filtro ao browse
	oBrowse:SetFilterDefault("ZDB_ROTINA = 'XAG0029'")// .AND. DTOS(ZDB_DATA) >= DDATABASE ")
 //	oBrowse:AddFilter("Data","DTOS(ZDB_DATA) == DTOS(DDATABASE)")
	//Desliga a exibição dos detalhes
//	oBrowse:DisableDetails()
	oBrowse:Activate()
Else
	Alert("Essa rotina só deve ser executada pela empresa Agricopel(01-01)")
Endif
Return()



User Function XAG029J()

LOCAL lret1:=.F.
Local cLinha  := ""
Local lPrim   := .T.
Local lPrimeiro := .F.
Local aCampos := {}
Local aDados  := {}
Local aLinha  := {}
Local cMascara  := "Arquivos TXT|*.TXT|Todos os arquivos|*.*"
Local cTitulo   := "Escolha o arquivo TXT com os dados do Senior para Importação "
Local nMascpad  := 1
Local cDirini   := "\"
Local lSalvar   := .T. /*.F. = Salva || .T. = Abre*/
Local nOpcoes   := GETF_LOCALHARD
Local lArvore   := .T. /*.T. = apresenta o árvore do servidor || .F. = não apresenta*/
Local cArq      := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)
Local _nRecnoSM0:= SM0->(RecNo())
Local _nOrdemSM0:= SM0->(IndexOrd())
Local  nStatus1 :=0
Local  cArqBKP  :=''

If !File(cArq)
	MsgStop("O arquivo " + cArq + " não foi encontrado. A importação será abortada!","[XAG0029] - ATENCAO")
	Return
EndIf
if !MsgYesNo("Confirma a importação dos Dados do arquivo "+CHR(13)+CHR(10)+upper(AllTrim(cArq)) + "?","ATENÇÃO")
	MsgInfo("Importação cancelada.","ATENÇÃO")
	Return Nil
endif

Processa( {|lEnd| XAG029LT(AllTrim(cArq))}, "Aguarde..."," Lendo Dados...TXT", .T. )
If AT(".",cArq)>0
	cArqBkp := SubStr(TRIM(cArq),1,AT(".TXT",UPPER(cArq))-1)+".BKP"
Else
	cArqBkp := TRIM(cArq)+".BKP"
Endif
nStatus1 := frenameEX(cArq,cArqBkp)
IF nStatus1 <> 0
	//	MsgStop('Não Foi possivel Renomear '+cARQBKP+' FError '+str(ferror()))
Endif
MsgInfo('Final da Integração Arquivo '+cArq,'Atencão')
Return Nil


Static Function XAG029LT(cArqTXT)

Local cLinha

Local lErro  := .F.
Local nLinha := 1
Local _cEmp:=''
Local alogSE2 := {}
Local aRecnoSM0 := {}
Local nOrdEmp	:= 0
Local nRecEmp	:= 0
Local cCodEmpAnt	:= Space(2)
local _nEmp:=0
Local nI:=0
local nPos
local _nParcela:=0
local _cCod:=''
local cQueryEmp    := ""
local cEmpQry      := ""
local cQueryFor    := ""
local cCodFor      := ""
local cLojaFor     := ""
local cNaturezaFor := ""
local cLenFornece  := 0

Private aDados := {}
private lProc:=.T.
Private aPosFil:={}
Private _cEmp:=''
Private oProcess  := NIL

PUBLIC lF50PERGUNT:=.F.
PUBLIC __LOGQUERY:=.F.

dbSelectArea("SM0")
nOrdEmp	:= IndexOrd()
nRecEmp	:= Recno()
aEspEmp:={}

FT_FUSE(cArqTXT)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
/*VERIFICAR LAYOUT TXT CORRETO
Campo	Nome	Tipo	Tamanho
E2_FILIAL 	Filial  	C	2
E2_PREFIXO	Prefixo 	C	3
E2_NUMERO 	Numero  	C	9
E2_PARCELA	Parcela 	C	2
E2_TIPO   	Tipo    	C	2
E2_NATUREZ	Natureza	C	10
E2_FORNECE	Fornecedor  	C	6
E2_LOJA   	Loja Forn   	C	2
E2_EMISSAO	Data Emssao 	D	8
E2_VENCTO 	Dt.Vencimento	D	8
E2_VENCREA	Dt.Venc.Real	D	8
E2_VALOR  	Valor Titulo	N	17,2
E2_HIST   	Historico   	C	70
*/

while !FT_FEOF()
	
	IncProc("Lendo arquivo : "+cArqTXT+" - "+AllTrim(Str(nLinha))+" de "+AllTrim(Str(FT_FLASTREC())))
	
	cLinha := FT_FREADLN()	

	// Obter a empresa baseado na informacao que vem no arquivo do Senior
	cQueryEmp := ""
	cEmpQry   := ""

    // Comentado esse alert que foi incluido para testar breakpoint
    //Alert("Essa rotina só deve ser executada pela empresa Agricopel(01-01)")

	cQueryEmp := ""
	cQueryEmp += "SELECT * "
	cQueryEmp += "FROM EMPRESAS (NOLOCK) "
	cQueryEmp += "WHERE EMP_CNPJ = '"+ALLTRIM(substr(cLinha,201,214))+"' "

	If Select("CNPJARQ") <> 0
		dbSelectArea("CNPJARQ")
		dbCloseArea()
	Endif

	TCQuery cQueryEmp NEW ALIAS "CNPJARQ"

	DbSelectArea("CNPJARQ")
	DbGoTop()
	While !Eof()	
		cEmpQry:= alltrim(CNPJARQ->EMP_COD)	
		CNPJARQ->(DbSkip())
	End

	If Select("CNPJARQ") <> 0
	 	dbSelectArea("CNPJARQ")
	 	dbCloseArea()
	Endif

	// Obter a empresa baseado na informacao que vem no arquivo do Senior
	cQueryFor := ""

    cCodFor      := ""
    cLojaFor     := ""
	cNaturezaFor := ""
	cNomfor      := ""

	cLenFornece  := Len(ALLTRIM(substr(cLinha,29,15)))
    cCodFor      := ALLTRIM(substr(cLinha,29,cLenFornece - 2))
    cLojaFor     := substr(ALLTRIM(cLinha),29+(cLenFornece-2),2)

	// Alterado o local da busca do fornecedor 
	cQueryFor := " SELECT A2_COD,A2_LOJA,A2_NATUREZ,A2_NREDUZ FROM "+RETSQLNAME("SA2")+" A2 (nolock) "
	cQueryFor += " WHERE D_E_L_E_T_ = ' ' "	

	if cLenFornece < 11 // menor que 11 caracteres pesquisa pelo código e loja do fornecedor
	   cQueryFor += " AND (A2_COD = '"+cCodFor+"' AND A2_LOJA = '"+cLojaFor+"') "
	Else  // maior ou igual que 11 caracteres pesquisa pelo cpf ou cnpj do fornecedor
	   cCodFor   := ALLTRIM(substr(cLinha,29,15))
	   cQueryFor += " AND (A2_CGC = '"+ALLTRIM(substr(cLinha,29,15))+"')  "	
    EndIf	   

    // comentado alert para verificar o sql inicial
    //Alert("SQL 01" + cQueryFor)

	If Select("FORNARQ") <> 0
		dbSelectArea("FORNARQ")
		dbCloseArea()
	Endif
    
	TCQuery cQueryFor NEW ALIAS "FORNARQ"

    DbSelectArea("FORNARQ")
	FORNARQ->(DbGoTop())
	while FORNARQ->(!Eof())
		cCodFor      := FORNARQ->A2_COD
		cLojaFor     := FORNARQ->A2_LOJA
		cNaturezaFor := FORNARQ->A2_NATUREZ
		cNomfor      := FORNARQ->A2_NREDUZ
		msunlock()
		FORNARQ->(DbSkip())
	enddo

	If Select("FORNARQ") <> 0
	 	dbSelectArea("FORNARQ")
	 	dbCloseArea()
	Endif
	// Alterado o local da busca do fornecedor 

	aadd(aDados,{ALLTRIM(substr(cLinha,1,14)),;                                  //'FILIAL'
	ALLTRIM(cEmpQry),;                                                           //'EMPRESA'
	ALLTRIM(substr(cLinha,29,8)),;                                               //'ZEROS'
	CTOD(substr(cLinha,46,2)+'/'+substr(cLinha,48,2)+'/'+substr(cLinha,50,4)),;  //'EMISSAO' 46
	CTOD(substr(cLinha,54,2)+'/'+substr(cLinha,56,2)+'/'+substr(cLinha,58,4)),;  //'VENCTO'  62
	CTOD(substr(cLinha,54,2)+'/'+substr(cLinha,56,2)+'/'+substr(cLinha,58,4)),;  //'VENCREA'
	Val(strtran(substr(cLinha,70,16),",",".")),;                                 //'VALOR'
	ALLTRIM(cCodFor),;                                                           //'CODIGO FORNECE'
	ALLTRIM(cLojaFor),;                                                          //'LOJA FORNECE'
	ALLTRIM(cNomfor),;                                                           //'NOME FORNECE'
    ALLTRIM(cNaturezaFor),;                                                      //'NATUREZA FORNECE'
	ALLTRIM(substr(cLinha,62,8)),;                                               //'PERIODO'
	ALLTRIM(cArqTXT)})                                                           //'ARQUIVO LEITURA'
	FT_FSKIP()
	nLinha++
enddo

FT_FUSE(cArqTXT) //fecha o arquivo
if len(aDADOS) < 1
	MsgStop("O arquivo " + cArqTXT + " Vazio, A importação será abortada!","[XAG0029] - ATENCAO")
Endif
ASort(aDADOS,,,{|x,y| x[2]+x[1] < y[2]+y[1]}) //Ordena por empresa
dbSelectArea("SM0")
dbGotop()
ProcRegua(Reccount())
While !Eof()
	
	IncProc("Preparando registros para importação" +cArqTXT)
	
	if ( nPos := aScan( aDados,{ |x,y| AllTrim(x[2]) == AllTrim(SM0->M0_CODIGO)})) > 0  //se tem no adados ENTRA NA ROTINA
		IF SM0->M0_CODFIL = '01' //SOMENTE A 01 ASSIM RODA UMA VEZ PARA TODAS AS FILIAIS
			Aadd(aRecnoSM0,SM0->M0_CODIGO)
		Endif
	Endif
	IF _cCod <> SM0->M0_CODIGO
		_nParcela:=0
		_cCod:=SM0->M0_CODIGO
	Endif
	_nParcela++  //Posicionamento da filial para a parcela
	Aadd(aPosFil,{SM0->M0_CODIGO+alltrim(SM0->M0_CODFIL),_nParcela})
	dbSkip()
EndDo
dbSelectarea("SM0")
dbSetOrder(nOrdEmp)
dbGoto(nRecEmp)
For nI := 1 To Len(aRecnoSM0)
	_cEmp:=aRecnoSM0[nI]
	lproc:=IF(_cEmp == '01',.T.,.F.)
	IF 	lproc ==.F. //NAO MOSTRA O PROCESSO EMPRESA DIFERENTE 01.
		MsgRun("Integrando Folha Senior -> Empresa: "+_cEmp  , "Executando Importação Outras Empresas ",{ ||CursorWait(),StartJob("U_PR029EM",GetEnvServer(),.T.,_cEmp,aDados,lproc,Aposfil,)})
		//chama via job para poder processar as empresas sem ZDB...
	Else
		oProcess := MsNewProcess():New( { | lEnd | U_Proc029(_cEmp,aDados,lproc,Aposfil)}, "Integrando Folha Senior - Aguarde..." , "Executando Importação",.T.)
		oProcess:Activate()
	Endif
Next nI
dbSelectarea("SM0")
dbSetOrder(nOrdEmp)
dbGoto(nRecEmp)
Return

//chama via job empresa a empresa para poder processar as empresas sem ZDB e gravar a cada empresa.
User Function PR029EM(_cEmp,aDados,lproc,Aposfil)
Local lClearEnv := .T.
Local aTabelas   := {"SA1","SA2","SA6","SA3","AKA","AK1","AKI","AKS","AKT","CT0","CT1","CT2","CTD","CTT","CVL","CTK","CT5","CTO","CV4",;
"SE1","SE2","SE3","SED","SE5","SES","FK1","SM2","FRP","DAK","SF1","SX5","FK2","SYA","SYB"}

PUBLIC lF50PERGUNT:=.F.
PUBLIC __LOGQUERY:=.F.

RpcSetType(3)
RpcSetEnv(_cEmp,,"","","FIN","XAG0029 - "+_cEmp,atabelas)
U_Proc029(_cEmp,aDados,lproc,Aposfil)
RpcClearEnv()
Return

//Faz o processamente da folha
User Function Proc029(_cEmp,aDados,lproc,aposfil)

//LE O TXT e gera TRBSE2 identico ao SE2
//GERA FINANCEIRO CHAMANDO A FINA050
//GRAVA LOGS NA ZDB

local cfil:=''
Local aSavSM0:={}
Local aArqTrab := {}
Local cTabAux  := ""
Local aTitulo := {}
Local aParcela := {'A  ','B  ','C  ','D  ','E  ','F  ','G  ','H  ','I  ','J  ','K  ','L  ','M  ','N  ','O  ','P  ','Q  ','R  ','S  ','T  ','U  ','V  ','X  ','Z  '}
LOCAL cQuery:=''
Local cAliasTmp  := GetNextAlias()
local _nParcela:=0
Local linclui:=.t.
local A:=0
local cFilAntBkp := ""
Private aLOGS:={}
Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .F.
Dbselectarea("SM0")
aSavSM0:={Alias(),IndexOrd(),Recno()}

aadd(aArqTrab,{"E2MSEMP"   ,"C",2,0})
aadd(aArqTrab,{"E2MSFIL"  ,TamSX3("E2_FILIAL")[3]  ,TamSX3("E2_FILIAL")[1]  ,TamSX3("E2_FILIAL")[2] })
aadd(aArqTrab,{"E2FILIAL"  ,TamSX3("E2_FILIAL")[3]  ,TamSX3("E2_FILIAL")[1]  ,TamSX3("E2_FILIAL")[2] })
aadd(aArqTrab,{"E2PREFIXO" ,TamSX3("E2_PREFIXO")[3] ,TamSX3("E2_PREFIXO")[1] ,TamSX3("E2_PREFIXO")[2]})
aadd(aArqTrab,{"E2NUM"     ,TamSX3("E2_NUM")[3]     ,TamSX3("E2_NUM")[1]     ,TamSX3("E2_NUM")[2]    })
aadd(aArqTrab,{"E2PARCELA" ,TamSX3("E2_PARCELA")[3] ,TamSX3("E2_PARCELA")[1]   ,TamSX3("E2_PARCELA")[2]    })
aadd(aArqTrab,{"E2TIPO"    ,TamSX3("E2_TIPO")[3]    ,TamSX3("E2_TIPO")[1]    ,TamSX3("E2_TIPO")[2]   })
aadd(aArqTrab,{"E2NATUREZ" ,TamSX3("E2_NATUREZ")[3] ,TamSX3("E2_NATUREZ")[1] ,TamSX3("E2_NATUREZ")[2]})
aadd(aArqTrab,{"E2FORNECE" ,TamSX3("E2_FORNECE")[3] ,TamSX3("E2_FORNECE")[1] ,TamSX3("E2_FORNECE")[2]})
aadd(aArqTrab,{"E2LOJA"    ,TamSX3("E2_LOJA")[3]    ,TamSX3("E2_LOJA")[1]    ,TamSX3("E2_LOJA")[2]   })
aadd(aArqTrab,{"E2EMISSAO" ,TamSX3("E2_EMISSAO")[3] ,TamSX3("E2_EMISSAO")[1] ,TamSX3("E2_EMISSAO")[2]})
aadd(aArqTrab,{"E2VENCTO"  ,TamSX3("E2_VENCTO")[3]  ,TamSX3("E2_VENCTO")[1]  ,TamSX3("E2_VENCTO")[2] })
aadd(aArqTrab,{"E2VENCREA" ,TamSX3("E2_VENCREA")[3] ,TamSX3("E2_VENCREA")[1] ,TamSX3("E2_VENCREA")[2]})
aadd(aArqTrab,{"E2VALOR"   ,TamSX3("E2_VALOR")[3]   ,TamSX3("E2_VALOR")[1]   ,TamSX3("E2_VALOR")[2]  })
aadd(aArqTrab,{"E2HIST"    ,TamSX3("E2_HIST")[3]    ,TamSX3("E2_HIST")[1]    ,TamSX3("E2_HIST")[2]   })
aadd(aArqTrab,{"E2ORIGEM"  ,TamSX3("E2_ORIGEM")[3]  ,TamSX3("E2_ORIGEM")[1]  ,TamSX3("E2_ORIGEM")[2] })
aadd(aArqTrab,{"E2EMIS1"   ,TamSX3("E2_EMIS1")[3]   ,TamSX3("E2_EMIS1")[1]   ,TamSX3("E2_EMIS1")[2]  })
aadd(aArqTrab,{"E2VENCORI" ,TamSX3("E2_VENCORI")[3] ,TamSX3("E2_VENCORI")[1] ,TamSX3("E2_VENCORI")[2]})
aadd(aArqTrab,{"E2SALDO"   ,TamSX3("E2_SALDO")[3]   ,TamSX3("E2_SALDO")[1]   ,TamSX3("E2_SALDO")[2]  })
aadd(aArqTrab,{"E2MOEDA"   ,TamSX3("E2_MOEDA")[3]   ,TamSX3("E2_MOEDA")[1]   ,TamSX3("E2_MOEDA")[2]  })
aadd(aArqTrab,{"E2NOMFOR"  ,TamSX3("A2_NOME")[3]  ,TamSX3("A2_NOME")[1]  ,TamSX3("A2_NOME")[2] })
aadd(aArqTrab,{"E2CTA"     ,TamSX3("E2_CTA")[3]  ,TamSX3("E2_CTA")[1]  ,TamSX3("E2_CTA")[2] })
aadd(aArqTrab,{"E2ARQLEI"  ,TamSX3("A2_NOME")[3]  ,TamSX3("A2_NOME")[1]  ,TamSX3("A2_NOME")[2] })
aadd(aArqTrab,{"E2LOG"   ,"C",1,0})

cTabAux := CriaTrab(aArqTrab, .T.)
DbCreate(cTabAux, aArqTrab)
cInd := LEFT(cTabAux, 7) + "1"

Iif(Select('TRBSE2') > 0, TRBSE2->(DbCloseArea()),)
DbUseArea(.T., , cTabAux, 'TRBSE2', .F., .F.)
IndRegua('TRBSE2', cInd, "E2MSEMP+E2MSFIL")    //Indice de organização do relatório
TRBSE2->(DbClearIndex())
DbSetIndex(cInd + OrdBagExt())

if lProc
	oProcess:SetRegua1(len(aDADOS))
Endif

For A:=1 TO len(aDADOS)
	
	//1'FILIAL'
	//2'EMPRESA'
	//3'ZEROS'
	//4'EMISSAO'
	//5'VENCTO'
	//6'VENCREA'
	//7'VALOR'
	//8'CODIGOFORNECE'
	//9'LOJA'
	//10'NOMFOR'
	//11'NATUREZAFOR' 
	//12'PERIODO'
	//13'ARQUIVO LEITURA'
	//14'CONTROLE INTERNO'
	
	if lProc
		oProcess:IncRegua1('Lendo Dados Para gravação ')
	Endif
	
	IF alltrim(aDados[A][2]) == alltrim(_cEmp)
		
		cfil    := aDados[A][1]
		nValor  := aDados[A][7]

		//cNomfor := aDados[A][10]  //UTILIZO ATUALMENTE PARA ACHAR O FORNECEDOR VERIFICAR TRATAMENTO E GRAVAR NA TABELA
		
		cMes:=strzero(month(aDados[A][4]),2)
		cAno:=strzero(Year(aDados[A][4]),4)
		cNum := StrZero(VAL(cMES+cAno), 9) // montagem do numero do titulo, mes e ano da data de emissao e completa com zeros a esquerda
		
		_nParcela := aScan(aPosfil,{ |x| Alltrim(x[1]) == _cemp+alltrim(cfil) } )
		_nParcela := if(_nParcela=0,1,aPosfil[_nParcela][2])
		if len(aparcela) < _nParcela
			_nParcela:=1
		Endif
		Reclock('TRBSE2',.T.)
		TRBSE2->E2FILIAL   := ' '
		TRBSE2->E2MSEMP    := _cemp
		TRBSE2->E2MSFIL    := cfil
		TRBSE2->E2PREFIXO  := cfil  //'FOL' //STRZERO(A,3)
		TRBSE2->E2NUM      := cNum
		TRBSE2->E2PARCELA  := Alltrim(aParcela[_nParcela])
		TRBSE2->E2TIPO     := 'TX'  //FIXO UTILIZADO NOS LANCAMENTOS ANTERIORES
		TRBSE2->E2NATUREZ  := ''
		TRBSE2->E2EMISSAO  := aDados[A][4]
		TRBSE2->E2VENCTO   := aDados[A][5]
		TRBSE2->E2VENCREA  := aDados[A][6]
		TRBSE2->E2VALOR    := nValor
		TRBSE2->E2HIST     := aDados[A][8]+'/'+aDados[A][9]+' '+aDados[A][12] //JUNTANDO NOME VINDO MAIS HISTORICO.. VER SE É NECESSARIO
		TRBSE2->E2ORIGEM   := 'FINA050'     //OBRIGATORIO .. CASO NEGATIVO NÃO CONSEGUE TRATAR NO CONTAS A PAGAR
		TRBSE2->E2VENCORI  := aDados[A][6]
		TRBSE2->E2SALDO    := nValor
		TRBSE2->E2MOEDA    := 1
		TRBSE2->E2FORNECE  := aDados[A][8]
		TRBSE2->E2CTA      := '' //FIXO VERIFICAR CONTAS PARA CONTABILIZAÇÃO.
		TRBSE2->E2LOJA     := aDados[A][9]
		TRBSE2->E2NOMFOR   := aDados[A][10]
		TRBSE2->E2ARQLEI   := aDados[A][13]
		msunlock()
	Endif
Next A
SX1->( dbSetOrder(1) )
nTam:=Len(SX1->X1_GRUPO)
If SX1->(dbSeek( Padr('FIN050',nTam)+"01" ) )
	Dbselectarea("SX1")
	reclock("SX1",.F.)
	SX1->X1_PRESEL:=2 //PARA NAO MOSTRAR OS LANCAMENTOS ..
	msunlock()
Endif

//oProcess:IncRegua1('Lendo Dados')
Dbselectarea("TRBSE2")
Dbgotop()
if lProc
	oProcess:SetRegua2(Reccount())
Endif

// Guarda a filial corrente que está logado antes de executar insercao do titulo
cFilAntBkp := cFilAnt
While !EOF()
	
	if lProc
		oProcess:IncRegua2('Empresa/Filial '+TRBSE2->E2MSEMP+TRBSE2->E2MSFIL)
	Endif
	
	//VERIFICAR TRATAMENTO DE FORNECEDOR CORRETO
	// Alterado por Thiago 22/05/2019 o local da busca do fornecedor 
	cQuery := " SELECT A2_COD,A2_LOJA,A2_NATUREZ,A2_NREDUZ FROM "+RETSQLNAME("SA2")+" A2 (NOLOCK) "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	//cQuery += " AND (A2_NOME = '"+TRBSE2->E2NOMFOR+"' OR A2_NREDUZ = '"+TRBSE2->E2NOMFOR+"')"
	cQuery += " AND (A2_COD = '"+TRBSE2->E2FORNECE+"' AND A2_LOJA = '"+TRBSE2->E2LOJA+"')"
	
	// comentado sql que valida existencia do fornecedor
	//Alert("SQL 02" + cQuery)

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSA2",.F.,.T.)
	TRBSA2->(DbGoTop())
	while TRBSA2->(!Eof())
		Reclock("TRBSE2",.F.)
		TRBSE2->E2FORNECE := TRBSA2->A2_COD
		TRBSE2->E2LOJA    := TRBSA2->A2_LOJA
		TRBSE2->E2NATUREZ := TRBSA2->A2_NATUREZ
		TRBSE2->E2NOMFOR  := TRBSA2->A2_NREDUZ
		msunlock()
		TRBSA2->(DbSkip())
	enddo
	TRBSA2->( dbCloseArea() )
	// Alterado por Thiago 22/05/2019 o local da busca do fornecedor 
	
	linclui:=.T.
	aTitulo := {}
	if Empty(TRBSE2->E2FORNECE)
		LerLogErro(.T.,.T.,'Codigo Fornecedor NAO encontrado --> '+TRBSE2->E2FORNECE+'/'+TRBSE2->E2LOJA)
		linclui:=.F.
	Endif
	if Empty(TRBSE2->E2NATUREZ) .and. linclui == .T.
		LerLogErro(.T.,.T.,'Natureza NÃO Cadastrada Para o Fornecedor -> '+TRBSE2->E2FORNECE+'/'+TRBSE2->E2LOJA)
		linclui:=.F.
	Endif
	IF linclui
		//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		_cFilial:= if(!EMPTY(xFilial("SE2")),TRBSE2->E2MSFIL,xFilial("SE2"))  //VERIFICO COMO GRAVA O SE2
		
		Dbselectarea("SE2")
		Dbsetorder(1)
		IF !Dbseek(_cFilial+TRBSE2->E2PREFIXO+TRBSE2->E2NUM+TRBSE2->E2PARCELA+TRBSE2->E2TIPO+TRBSE2->E2FORNECE+TRBSE2->E2LOJA)
			
			// Altera a filial corrente que está logado para poder inserir o titulo com E2_MSFIL igual
			// ao codigo da filial que eu desejo
			cFilAnt := TRBSE2->E2MSFIL

			//SE NAO ENCONTROU CRIA O REGISTRO
			Begin Transaction
			lMsErroAuto    := .F.
			lMsHelpAuto    := .T.
			lAutoErrNoFile := .T.
			AADD(aTitulo,{"E2_FILIAL",  _cFILIAL ,NIL})
			AADD(aTitulo,{"E2_MSFIL",   TRBSE2->E2MSFIL  ,NIL})
			AADD(aTitulo,{"E2_FILORIG", TRBSE2->E2MSFIL  ,NIL})
			AADD(aTitulo,{"E2_PREFIXO", TRBSE2->E2PREFIXO,NIL})
			AADD(aTitulo,{"E2_NUM",     TRBSE2->E2NUM    ,NIL})
			AADD(aTitulo,{"E2_PARCELA", TRBSE2->E2PARCELA,NIL})
			AADD(aTitulo,{"E2_TIPO",    TRBSE2->E2TIPO   ,NIL})
			AADD(aTitulo,{"E2_NATUREZ", TRBSE2->E2NATUREZ,NIL})
			AADD(aTitulo,{"E2_FORNECE", TRBSE2->E2FORNECE,NIL})
			AADD(aTitulo,{"E2_LOJA",    TRBSE2->E2LOJA   ,NIL})
			AADD(aTitulo,{"E2_EMISSAO", TRBSE2->E2EMISSAO,NIL})
			AADD(aTitulo,{"E2_VENCTO",  TRBSE2->E2VENCTO ,NIL})
			AADD(aTitulo,{"E2_VENCREA", TRBSE2->E2VENCREA,NIL})
			AADD(aTitulo,{"E2_VALOR",   TRBSE2->E2VALOR  ,NIL})
			AADD(aTitulo,{"E2_HIST",    TRBSE2->E2HIST   ,NIL})
			AADD(aTitulo,{"E2_ORIGEM",  TRBSE2->E2ORIGEM ,NIL})
			AADD(aTitulo,{"E2_EMIS1",   TRBSE2->E2EMIS1  ,NIL})
			AADD(aTitulo,{"E2_VENCORI", TRBSE2->E2VENCORI,NIL})
			AADD(aTitulo,{"E2_SALDO",   TRBSE2->E2SALDO  ,NIL})
			AADD(aTitulo,{"E2_MOEDA",   TRBSE2->E2MOEDA  ,NIL})
			AADD(aTitulo,{"E2_NOMFOR",  TRBSE2->E2NOMFOR ,NIL})
			AADD(aTitulo,{"E2_ORIIMP",  "XAG0029" ,NIL})       //FIXO PARA FILTROS E RELATORIOS
			AADD(aTitulo,{"E2_LA",      'N'           ,NIL})
			AADD(aTitulo,{"E2_CTA",     TRBSE2->E2CTA ,NIL})
			
			MSExecAuto({|x, y| FINA050(x, y)}, aTitulo,3,3,,,.F.,.T.) //CONTAS A PAGAR AUTO.
			
			If lMsErroAuto
				//	MostraErro()
				LerLogErro(.T.,.T.,'')  // GRAVA LOG DE ERRO DE INCLUSAO
				DisarmTransaction()
			Else
				LerLogErro(.F.,.F.,'')   //GRAVA LOG QUE ESTA OK O TITULO
			Endif
			End Transaction
		Else
			LerLogErro(.F.,.T.,'') //GRAVA LOG QUE TITULO JÁ EXISTE
		Endif
	Endif
	Dbselectarea("TRBSE2")
	Dbskip()
Enddo

// retorna a filial corrente para o codigo que esta guardado antes de executar insercao do titulo
cFilAnt := cFilAntBkp 

Iif(Select('TRBSE2') > 0, TRBSE2->(DbCloseArea()),)
//grava os logs a cada empresa
IF Len(aLOGS) > 0
	Sleep(5000)  //tempo para o processo
	IF 	lproc ==.F. //NAO MOSTRA O PROCESSO
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv('01',,"","","FIN","XAG29LOG",{"ZDB","SE2","SA2"})
		Dbselectarea("ZDB")
		U_XAG29LOG(aLOGS)
		RpcClearEnv()
	Else
		U_XAG29LOG(aLOGS)
	Endif
Endif
Sleep(5000)
RestArea(aSAVSM0)
Return

//Prepara o array com  log das rotinas

Static Function LerLogErro(llog,ltipo,cmsg)

Local cErro    := " "
Local aErroLog := GetAutoGRLog() //BUSCA DADOS DO LOG DE INCLUSAO
Local  ZDBFILIAL := ' '//TRBSE2->E2MSFIL
Local  ZDBEMP    := TRBSE2->E2MSEMP  //Empresa do grupo que será gravado o registro
Local  ZDBDESCRO := 'Inclusão CP Folha '+TRBSE2->E2MSEMP+TRBSE2->E2MSFIL  //Descrição da rotina
Local  ZDBDATA   := Ddatabase //data
Local  ZDBHORA   := Time()  //Horario
Local  ZDBTAB    := 'SE2'  //tabela de gravacao
Local  ZDBROTINA := 'XAG0029' // Rotina de gravaça
Local  ZDBINDICE := '1'  //indice utilizado para pesquisa
Local  ZDBCHAVE  := TRBSE2->E2MSEMP+TRBSE2->E2MSFIL+TRBSE2->E2FILIAL+TRBSE2->E2PREFIXO+TRBSE2->E2NUM+TRBSE2->E2PARCELA+TRBSE2->E2TIPO+TRBSE2->E2FORNECE+TRBSE2->E2LOJA  //chave pesquisa
Local  ZDBDBEMP  := TRBSE2->E2MSEMP
Local  ZDBDBFIL  :=  TRBSE2->E2MSFIL
Local  ZDBDBCHAV := TRBSE2->E2ARQLEI
Local  ZDBTIPOWF := 0  // TIPO WF
Local  ZDBMSG    := IF(llog==.F..and. ltipo == .T.,'Já Existe Este Documento '+ZDBCHAVE,'')  //mensagem de ERRO
Local  ZDBMSGLOG := ''
Local  ZDBVALOR  :=TRBSE2->E2VALOR
Local   N:=0

ZDBMSG := IF(llog==.F. .and. ltipo == .F.,'Documento Incluido '+ZDBCHAVE,ZDBMSG)  //mensagem de ERRO
ZDBMSG := IF(!EMPTY(cmsg),alltrim(cmsg),alltrim(ZDBMSG))

IF Len(aErroLog) > 0 //ERRO LOG DE INCLUSAO PADRÃO
	for N := 1 to Len(aErroLog)
		ZDBMSGLOG += AllTrim(aErroLog[n])+CHR(13)+CHR(10)
		ZDBMSG  := "Erro na inclusão "+ZDBCHAVE
	next
EndIf
IF UPPER(substr(ZDBMSGLOG,1,15)) == 'ERRO NO GATILHO' .AND. EMPTY(TRBSE2->E2LOG) //ERRO DE CHAMADA NO PROCESSO
	Dbselectarea("TRBSE2")
	Reclock("TRBSE2",.F.)
	TRBSE2->E2LOG:='X'
	msunlock()
	ZDBMSGLOG += 'ERRO GAT'
	Dbselectarea("TRBSE2")
	Dbskip(-2)
	Return()
Endif


AADD(aLogs,{;
{'ZDB_EMP'	  ,ZDBEMP},;
{'ZDB_FILIAL' ,ZDBFILIAL},;
{'ZDB_MSG'	  ,ZDBMSG},;
{'ZDB_DATA'	  ,ddatabase},;
{'ZDB_HORA'	  ,time()},;
{'ZDB_TAB' 	  ,'SE2'},;
{'ZDB_INDICE' ,1},;
{'ZDB_CHAVE'  ,ZDBCHAVE},;
{'ZDB_TIPOWF' ,0},;
{'ZDB_DESCRO' ,ZDBDESCRO},;
{'ZDB_ROTINA' ,'XAG0029'},;
{'ZDB_DBEMP'  ,ZDBDBEMP},;
{'ZDB_DBFIL'  ,ZDBDBFIL},;
{'ZDB_VALOR'  ,ZDBVALOR},;
{'ZDB_DBFIL'  ,ZDBDBFIL},;
{'ZDB_MSGLOG' ,ZDBMSGLOG},;
{'ZDB_DBCHAV' ,ZDBDBCHAV};
})
Return()


User Function XAG29LOG(aLOGS)

LOCAL I:=0

//Grava dados
For i := 1 to len(aLogs)
	Dbselectarea("ZDB")
	Reclock("ZDB",.T.)
	For Z := 1 to len(aLogs[i])
		//Formata Registros
		_cTypeCampo := valtype(&(aLogs[i][z][1])) //aLogs[i][z][1]
		_cTypeReg   := valtype(aLogs[i][z][2])   //aLogs[i][z][2]
		
		If _cTypeCampo == _cTypeReg
			&(aLogs[i][z][1]) := aLogs[i][z][2]
		Else
			If _cTypeCampo == 'C'
				If _cTypeReg == 'N'
					&(aLogs[i][z][1]) := alltrim(str(aLogs[i][z][2]))
				ElseIF _cTypeReg == 'D'
					&(aLogs[i][z][1]) := dtos(aLogs[i][z][2])
				Endif
			Elseif _cTypeCampo == 'D'
				if _cTypeReg == 'C'
					&(aLogs[i][z][1]) := ctod(aLogs[i][z][2])
				Endif
			Elseif  _cTypeCampo == 'N'
				if _cTypeReg == 'C'
					&(aLogs[i][z][1]) := val(aLogs[i][z][2])
				Endif
			Endif
		Endif
	Next z
	ZDB->(MsUnlock())
Next i
Return

/*
Campo       Nome          Tipo    Tamanho
E2_FILIAL 	Filial          C       2
E2_PREFIXO	Prefixo         C       3
E2_NUMERO 	Numero          C       9
E2_PARCELA	Parcela         C       2
E2_TIPO   	Tipo            C       2
E2_NATUREZ	Natureza        C      10
E2_FORNECE	Fornecedor  	C       6
E2_LOJA   	Loja Forn   	C       2
E2_EMISSAO	Data Emssao 	D       8
E2_VENCTO 	Dt.Vencimento	D       8
E2_VENCREA	Dt.Venc.Real	D       8
E2_VALOR  	Valor Titulo	N      17,2
E2_HIST   	Historico   	C      70
*/

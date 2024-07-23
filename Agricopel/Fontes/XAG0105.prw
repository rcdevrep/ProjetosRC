
#include 'Totvs.ch'
#include 'TOPConn.ch'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include "AP5MAIL.CH"
#Include "TBICONN.CH"					 

#DEFINE cEOL Chr(13)+Chr(10) // Fim de linha e próxima linha

// Estrutura de pastas de arquivos para leitura 
#Define DIRALER  "NEW\"
#Define DIRLIDO  "OLD\"
#Define DIRERRO  "ERR\"

// Diretórios para remessa e retorno
#Define DIRREM  "REMESSA\"
//#Define DIRRET  "RETORNO\"


//-------------------------------------------------------------------
/*/{Protheus.doc} XAG0105
ENVIO DE PEDIDOS PARA MAXTON

@author JÚNIOR CONTE
@since 06/01/2023
/*/
//-------------------------------------------------------------------
**********************
User Function XAG0105()
**********************
**********************

Local aRet := {}

// Parametros da rotina
Private cPerg 		:= "XAG0105"
Private aRotina 	:= {} 
// Filtro conforme Parâmetros do Usuário
Private _cFiltro 	:= ""
Private _cDescDep 	:= ""
Private _cAGEP		:= ""

// Caminho padrão para a manipulação dos arquivos
Private _cDirCONF := "\maxton\"//SUPERGETMV("ML_XDIRPDR",.F.,'C:\maxton\') 

If ! ExistDir(_cDirCONF)
	MakeDir(_cDirCONF)
EndIf

if alltrim(cFilant) <> "19"
	Return()
endif
	

// Parametros da rotina
//sfCriaPerg(cPerg)

AtuSX1()
If !Pergunte(cPerg,.T.)
	Return()
Else

    If (MV_PAR07 <> '20' .OR. MV_PAR08 <> '20')
        If !(MsgYesNo("Você selecionou um Armazem diferente de 20, deseja continuar?  ", '          #####   ATENÇÃO   ##### '))
            Return
        Endif   
    Endif 

EndIF

//-- Cria os diretorios para integração
If !ExistDir("\maxton\")	
	// Garante Criação das pastas remessa de lidas, erro e pendentes
	MAKEDIR("\maxton\")
	MAKEDIR("\maxton\" + DIRREM)
	MAKEDIR("\maxton\" + DIRREM +DIRALER)
	MAKEDIR("\maxton\" + DIRREM +DIRERRO)
	MAKEDIR("\maxton\" + DIRREM +DIRLIDO)	
	// Garante Criação dasoBrowseSC9 pastas retorno de lidas, erro e pendentes
	
EndIF
// Monta a tela conforme os parâmetros
sfTela()

Return()


// Monta a tela para o Usuário
Static Function sfTela()
************************

Local aCoors   := FWGetDialogSize( oMainWnd )
Local oPanelUp, oFWLayer, oPanelDown

// Definição de fontes
Local oFontN15   := TFont():New( "Arial",0,-20,,.T.,0,,700,.F.,.F.,,,,,, )

Private oDlgPrinc, oBrowseSC9, oSayDep 

aCpos := {}


// Tecla de atalho para parâmetros
SetKey(VK_F5,  { ||  MsAguarde( {|| U_XAG0105D() }, "Atualizando..." ) } )
SetKey(VK_F12, { ||  U_XAG0105P() } )

Define MsDialog oDlgPrinc Title 'Envio de txt de pedidos para a maxton' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

//
// Cria o conteiner onde serão colocados os browses
//
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )

//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 10, .F. )                       // Cria uma "linha" com 10% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )            // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )         // Pego o objeto desse pedaço do container
// Nome do Depositante
oSayDep  := TSay():New( 012,004,{||_cDescDep},oPanelUp,,oFontN15,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,350,012)
//
// Painel Inferior
//
oFWLayer:AddLine( 'DOWN', 90, .F. )                     // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL' ,  100, .T., 'DOWN' )        // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelDown  := oFWLayer:GetColPanel( 'ALL' , 'DOWN' )   // Pego o objeto desse pedaço do container

//
// FWmBrowse Superior Cabecalho Pre Pedido de Venda
//
oBrowseSC9:= FWMarkBrowse():New()
oBrowseSC9:SetOwner( oPanelDown )                          // Aqui se associa o browse ao componente de tela
oBrowseSC9:SetDescription( 'Envio EDI maxton' )
oBrowseSC9:SetAlias( 'SC9' )
oBrowseSC9:SetFieldMark( 'C9_OK' )
//oBrowseSC9:SetFields(aCpos) // Define os campos a serem mostrados no MarkBrowse
oBrowseSC9:SetAllMark({|| sfMarcAll() }) // Indica o Code-Block executado no clique do header da coluna de marca/desmarca
oBrowseSC9:SetCustomMarkRec({|| sfMarca() }) // Indica o Code-Block executado para marcação/desmarcação customizada do registro
// Monta o filtro conforme os parametros
_cFiltro := sfMontaFiltro()
oBrowseSC9:SetFilterDefault( _cFiltro )      // Filtra somente os Pre Pedidos de Venda (0=Em andamento;1=Concluidos)
oBrowseSC9:SetMenuDef( 'XAG0105' )                        // Define de onde virao os botoes deste browse

oBrowseSC9:AddLegend( "C9_BLEST =='01'   .or. C9_BLEST =='02' ",  "BR_PRETO" 	, "Bloqueado Estoque" )
oBrowseSC9:AddLegend( "( C9_BLCRED == '01' .or. C9_BLCRED =='02') .and. C9_BLEST <>'01'  .and. C9_BLEST <>'02'  ", "BR_AZUL" 	, "Bloqueado Credito" )
oBrowseSC9:AddLegend( "( C9_BLEST <> '01' .AND. C9_BLCRED <>'01'  .AND. C9_BLEST <> '02' .AND. C9_BLCRED <>'02' .AND.  C9_BLEST <> '10' .AND. C9_BLCRED <> '10')  ", "BR_VERDE"     , "Liberado" )
oBrowseSC9:AddLegend( "( C9_BLEST == '10' .AND. C9_BLCRED == '10' ) ", "BR_VERMELHO"     , "Faturado" )

oBrowseSC9:DisableDetails()
//oBrowseSC9:SetProfileID( '10' )
oBrowseSC9:ForceQuitButton()
oBrowseSC9:SetAmbiente(.F.) // Desabilita a utilização da funcionalidade Ambiente no Browse
oBrowseSC9:SetWalkThru(.F.) // Desabilita a utilização da funcionalidade Walk-Thru no Browse

//
// Ativa o Browse
//
oBrowseSC9:Activate()

Activate MsDialog oDlgPrinc Center

// Limpa tecla de atalho
Set Key VK_F5  TO
Set Key VK_F12 TO

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} sfMarca

Validação e Marcação da linha.

@author JÚNIOR CONTE
@since 27/04/15
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function sfMarca()
*************************

Local _cMark := oBrowseSC9:cMark // Marcação 

// Desmarca
If SC9->C9_OK = _cMark 
   
        // Realiza a desmarcação
        RecLock("SC9",.F.)
        SC9->C9_OK := SPACE(2)
        SC9->(MsUnlock())
    
	Return()	
EndIF



// Realiza a marcação

DbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1") +  SC9->C9_PRODUTO )

 IF substr(SC9->C9_PRODUTO, len(alltrim(SC9->C9_PRODUTO))-2, 3) == "801" .AND. SB1->B1_TIPO == 'SH' 
    MsgAlert("Produto granel, verifique!", "XAG01105")
    return()
 endif

 //if ( SC9->C9_BLCRED == '10' .or. SC9->C9_BLCRED == '' )  .AND. (  SC9->C9_BLEST == '10' .AND. SC9->C9_BLEST == ' '  ) 
 if  SC9->C9_BLEST <> '01' .AND. SC9->C9_BLCRED <>'01'  .AND. SC9->C9_BLEST <> '02' .AND. SC9->C9_BLCRED <> '02'
    
    //And (trim(C9_PRODUTO) NOT LIKE '%801' AND B1_TIPO = 'SH'  ) 
  
        if !EMPTY(SC9->C9_XDTEDI)
            IF MsgYesNo('Pedido '+SC9->C9_PEDIDO+', Item '+SC9->C9_ITEM+ ' ja ENVIADO em'+DTOC(SC9->C9_XDTEDI)+' às '+SC9->C9_XHREDI+', deseja marcar mesmo assim?  ', "Sim ou Não.")
                RecLock("SC9",.F.)
                SC9->C9_OK := _cMark
                SC9->(MsUnlock())
            ENDIF
        Elseif SC9->C9_BLEST == '10'
            IF MsgYesNo('Pedido '+SC9->C9_PEDIDO+', Item '+SC9->C9_ITEM+ ' ja foi FATURADO e nao ENVIADO  , deseja marcar mesmo assim?  ', "Sim ou Não.")
                RecLock("SC9",.F.)
                SC9->C9_OK := _cMark
                SC9->(MsUnlock())
            ENDIF
        ELSE
            RecLock("SC9",.F.)
            SC9->C9_OK := _cMark
            SC9->(MsUnlock())
        ENDIF
   
 else    
     MsgAlert("Pedido Com Bloqueio, verifique!", "XAG0105")
 endif

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} sfMarcAll

Marcação/Inversão de marcação dos dados conforme o status.

@author Júnior
@since 06/01/23
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function sfMarcAll()
***************************

// Marcação
Local _cMark := oBrowseSC9:cMark

// Obs.: Neste momento os dados na tabela SF2 estão filtrados (set filter)
// conforme os parametros do usuário, por isso pode-se utilizar o While sem condições

// Inicio do Arquivo
SC9->(DBGOTOP())

While !SC9->(EOF())

    DbSelectArea("SB1")
    dbSetOrder(1)
    dbSeek(xFilial("SB1") +  SC9->C9_PRODUTO )

    IF  !(substr(SC9->C9_PRODUTO, len(alltrim(SC9->C9_PRODUTO))-2, 3) == "801" .AND. SB1->B1_TIPO == 'SH' )//!( ("801" $ ALLTRIM(SC9->C9_PRODUTO) ) .AND.  SB1->B1_TIPO = 'SH' )

	// Realiza a marcação ou inversão
		RecLock("SC9",.F.)
		If SC9->C9_OK = _cMark
			SC9->C9_OK := SPACE(2)
		Elseif   SC9->C9_BLEST <> '01' .AND. SC9->C9_BLCRED <>'01'  .AND. SC9->C9_BLEST <> '02' .AND. SC9->C9_BLCRED <> '02' // ( SC9->C9_BLCRED == '10' .or. SC9->C9_BLCRED == ' ' )  .AND. (  SC9->C9_BLEST == '10' .AND. SC9->C9_BLEST == ' '  ) 
			if  !EMPTY(SC9->C9_XDTEDI)
                IF MsgYesNo('Pedido '+SC9->C9_PEDIDO+', Item '+SC9->C9_ITEM+ ' ja ENVIADO em'+DTOC(SC9->C9_XDTEDI)+' às '+SC9->C9_XHREDI+' deseja marcar mesmo assim? ' , "Sim ou Não.")
                    SC9->C9_OK := _cMark
                Endif 
            Elseif SC9->C9_BLEST == '10'
                IF MsgYesNo('Pedido '+SC9->C9_PEDIDO+', Item '+SC9->C9_ITEM+ ' ja foi FATURADO e NAO ENVIADO , deseja marcar mesmo assim?  ', "Sim ou Não.")
                    RecLock("SC9",.F.)
                        SC9->C9_OK := _cMark
                    SC9->(MsUnlock())
                ENDIF
            Else
                SC9->C9_OK := _cMark
            Endif 
		ELSE              
           // MsgAlert("Pedido Com Bloqueio, verifique!", "XAG01105")
        ENDIF	
		SC9->(MsUnlock())
	
    Endif
	// Próximo registro filtrado
	SC9->(DBSKIP())

EndDo

// Atualiza a tela
oBrowseSC9:Refresh(.T.)

Return 



//-------------------------------------------------------------------
/*/{Protheus.doc} XAG0105P

Parametros para novo filtro no browser

@author Júnior 
@since 14/12/20
@version 1.0

/*/
//-------------------------------------------------------------------
***********************
User Function XAG0105P()
***********************
***********************

// Parametros
If Pergunte(cPerg,.T.)
	
	
    if (MV_PAR07 <> '20' .OR. MV_PAR08 <> '20')
        If !(MsgYesNo("Você selecionou um Armazem diferente de 20, deseja continuar?  ", ' ########### ATENÇÃO ########### '))
            Return
        Endif   
    Endif 


	// Atualiza filtro
	_cFiltro := sfMontaFiltro()	
	oBrowseSC9:SetFilterDefault(_cFiltro )
	
	// Atualiza a tela
	oSayDep:Refresh()
	oBrowseSC9:Refresh(.T.)

EndIF

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} XAG0105D

Atualizar Tela (F5)

@author Junior
@since 09/01/23
@version 1.0

/*/
//-------------------------------------------------------------------
***********************
User Function XAG0105D()
***********************
***********************
// Parametros
Pergunte(cPerg,.F.)
	
// Atualiza filtro
_cFiltro := sfMontaFiltro()	
oBrowseSC9:SetFilterDefault(_cFiltro )

// Atualiza a tela
oBrowseSC9:Refresh(.T.)
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} sfMontaFiltro

Montagem do filtro conforme os parâmetros

@author Júnior Conte
@since 08/01/23
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function sfMontaFiltro()
*******************************

_cFiltro :=  ""

_cFiltro +=  "  C9_FILIAL = '19' .AND. C9_DATALIB >= '"+DtoS(MV_PAR09)+"'   .AND.   C9_DATALIB <='"+DtoS(MV_PAR10)+"' " // --DATA DE CORTE
//_cFiltro +=  " .AND. C9_NFISCAL == ' ' "
_cFiltro +=  " .AND. C9_PEDIDO  >=  '"+(MV_PAR01)+"'  .AND.   C9_PEDIDO   <= '"+(MV_PAR02)+"' " 
_cFiltro +=  " .AND. C9_LOCAL   >=  '"+(MV_PAR07)+"'  .AND.   C9_LOCAL    <= '"+(MV_PAR08)+"' " 
_cFiltro +=  " .AND. C9_CLIENTE >=  '"+(MV_PAR03)+"'  .AND.   C9_CLIENTE  <= '"+(MV_PAR05)+"' "
_cFiltro +=  " .AND. C9_LOJA    >=  '"+(MV_PAR04)+"'  .AND.   C9_LOJA     <= '"+(MV_PAR06)+"' "
//_cFiltro +=  " .AND. C9_FILIAL  >=  '"+(MV_PAR05)+"'  .AND.   C9_FILIAL  <= '"+(MV_PAR06)+"' " 

if mv_par11 == 1
//_cFiltro +=  " .AND. C9_XSREDI = ' '  " 
elseif mv_par11 == 2
_cFiltro +=  " .AND. C9_XSREDI = ' '  " 
elseif mv_par11 == 3
_cFiltro +=  " .AND. C9_XSREDI <>  ' '  " 
elseif mv_par11 == 4
_cFiltro +=  " .AND. C9_XDTSEP =  ' '  " 
endif

//_cFiltro += " .AND. !( POSICIONE('SB1',1,SC9->C9_FILIAL+SC9->C9_PRODUTO,'B1_TIPO') == 'SH' .AND. SUBSTR(ALLTRIM(C9_PRODUTO),len(ALLTRIM(C9_PRODUTO))- 2, 3 ) == '801' )
//_cFiltro += "  .AND. SUBSTR(ALLTRIM(C9_PRODUTO),len(ALLTRIM(C9_PRODUTO))- 2, 3 ) == '801' ) "
Return _cFiltro




//-------------------------------------------------------------------
/*/{Protheus.doc} XAG0105

Exporta em arquivo TXT 

@author Júnior Conte
@since 07/01/23
@version 1.0

/*/
//-------------------------------------------------------------------
***********************
User Function XAG0105A()
***********************
***********************

// Marcação
Local _cMark := oBrowseSC9:cMark

// Auxiliares
Local _cMsg		:= ""
Local i			:= 0
Local _aChvErro := {}

// Auxilaires para SQL
Local cQUERY := ""
Private _cAli548W := "_QRYSC9_"
Private _nCont 	:= 0 // Total de registros 
// Notas com problemas na geração do arquivo 
Private _aErro := {}
Private _cDirCONF := "\maxton\"//SUPERGETMV("ML_XDIRPDR",.F.,'C:\maxton\') 



If (MV_PAR07 <> '20' .OR. MV_PAR08 <> '20')
    If !(MsgYesNo("Você utilizou filtro de Armazem diferente de 20, deseja continuar?  ", '          #####   ATENÇÃO   ##### '))
           Return
    Endif   
 Endif 

If ! ExistDir(_cDirCONF)
	MakeDir(_cDirCONF)
EndIf

//testo conexao ftp.

/*
if ! U_XAG0105E()
	MSGALERT("Erro ao conectar com o FTP maxton ",;
	"[XAG0105E] - Problema FTP:")
	return()
endif
*/
// Necessário fazer a QRY para obter os dados para melhorar a performance no processamento
// Verifica área
If Select(_cAli548W)<>0
	(_cAli548W)->(DbCloseArea())
EndIf

cQUERY :=  " SELECT  DISTINCT C9_FILIAL, C9_PEDIDO  "
cQuery +=  " FROM "+RetSQLName("SC9")+" SC9 "
cQUERY +=  " WHERE  SC9.D_E_L_E_T_ = ' ' AND C9_FILIAL = '"+xFilial("SF2")+"'  "

cQUERY +=  " AND C9_OK = '"+_cMark+"' " 

TcQuery cQuery New Alias (_cAli548W)
COUNT TO _nCont


// Processamento da rotina
Processa({|| sfProcessa(_cDirCONF, _cMark) },"Enviando para  maxton...")
If Select(_cAli548W)<>0
	(_cAli548W)->(DbCloseArea())
EndIf



// Atualiza a tela
oBrowseSC9:Refresh(.T.)

Return()


// Processamento dos itens selecionados
Static Function sfProcessa(_cDirCONF, _cMark)
****************************

Local _aRet := {}

// Tamanho da Barra de Progressão
ProcRegua(_nCont+1)

// Controle de erros.
_aErro := {}

// Inicio do arquivo Filtrado
(_cAli548W)->(DbGotop())
While !(_cAli548W)->(Eof())
	
	
	
	// Posiciona SC9
	//SC9->(DBGOTO((_cAli548W)->SC9RECNO))

	// Progressão
	Incproc("Gerando Arquivo para a maxton...")
		
	
	//_aRet := {}
	lRet := .F.

    lRet := RunCont( (_cAli548W)->C9_FILIAL, (_cAli548W)->C9_PEDIDO, _cMark )

		
	// Próximo registro
	(_cAli548W)->(DbSkip())

EndDo 

// Função para enviar itens pendentes para o FTP da maxton
Incproc("Enviando Arquivos para FTP WMS maxton...")
_aRet := {}


Return()


//-------------------------------------------_QRYSC9_------------------------
/*/{Protheus.doc} XAG0105C


@author Júnior Conte
@since 08/01/23
@version 1.0

/*/
//-------------------------------------------------------------------
***********************
User Function XAG0105C()
***********************
***********************
Local _aChaves 		:= {}
Local _cMark   		:= oBrowseSC9:cMark
Private _cAli548W 	:= "_QRYSC9_"

// Função que retorna tela com os log´s 


If Select(_cAli548W)<>0
	(_cAli548W)->(DbCloseArea())
EndIf

cQUERY :=  " SELECT  C9_PEDIDO "
cQUERY +=  " FROM "+RetSQLName("SC9")+" SC9 "
//cQUERY +=  " INNER JOIN  "+RetSQLName("SF2")+" SF2 ON SF2.F2_FILIAL = SC9.C9_FILIAL AND SF2.F2_DOC = SC9.C5_NOTA AND SF2.F2_SERIE = SC9.C5_SERIE "
cQUERY +=  " WHERE  SC9.D_E_L_E_T_ = ' ' AND C9_FILIAL = '"+xFilial("SF2")+"'  "
//cQUERY +=  " AND F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cQUERY +=  " AND C9_OK = '"+_cMark+"' " 
TcQuery cQUERY New Alias (_cAli548W)
COUNT TO _nCont

(_cAli548W)->(DbGotop())
While !(_cAli548W)->(Eof())

	AADD(_aChaves, {(_cAli548W)->(C5_NUM)})
		
	(_cAli548W)->(DbSkip())
EndDo
	
// Recebe: _aChvLog = Vetor com as chaves a serem filtradas para mostara na tela.
//U_KOM560(_aChaves)

Return()



Static Function AtuSX1()
Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local aDados   := {}
Local nI       := 0
Local nJ       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }


aAdd( aDados, {'XAG0105','01','Pedido  de' ,'Pedido de','Pedido de',  'mv_ch1','C',6,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','02','Pedido  ate','Pedido ate','Pedido Ate','mv_ch2','C',6,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','03','Cliente  De','Cliente  De','Cliente  De','mv_ch3','C',Tamsx3("A1_COD")[1],0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','04','Loja     De','Loja     De','Loja     De','mv_ch4','C',Tamsx3("A1_LOJA")[1],0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','05','Cliente  ate','Cliente  ate','Cliente  ate','mv_ch5','C',Tamsx3("A1_COD")[1],0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','06','Loja     ate','Loja     ate','Loja     ate','mv_ch6','C',Tamsx3("A1_LOJA")[1],0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','07','Armazem  de' ,'Armazem de', 'Armazem de',  'mv_ch7','C',Tamsx3("B2_LOCAL")[1],0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','08','Armazem  ate','Armazem ate','Armazem Ate', 'mv_ch8','C',Tamsx3("B2_LOCAL")[1],0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','09','Emissao de','Emissao de','Emissao de','mv_ch9','D',8,0,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','10','Emissao ate','Emissao ate','Emissao ate','mv_cha','D',8,0,0,'G','','MV_PAR10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
//AADD(aRegs,{cPerg1,"11","Status?"           ,"","","mv_chb","N",01,0,0,"C","","mv_par11","Todos","","","","","Baixados","","","","","Ativos","","","","","","","","","","","","","","","","","",""})
//aAdd( aDados, {'XAG0105','11','Mostrar     ','Mostara  ','Mostrar ','mv_chb','C',1,0,0,'C','','MV_PAR11','Todos','Nao Enviados','Enviados','Nao Separados','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','11','Mostrar     ','Mostara  ','Mostrar ','mv_chb','C',1,0,0,'C','','MV_PAR11','Todos','','','','','Nao Enviados','','','','','Enviados','','','','','Nao Separados','','','','','','','','','','','','','',''} )
/*
aAdd( aDados, {'XAG0105','01','Data Ini','Data Ini','Data Ini','mv_ch1','D',8,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','02','Data Fim','Data Fim','Data Fim','mv_ch2','D',8,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','03','Pedido de' ,'Pedido de','Pedido de','mv_ch3','C',6,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','04','Pedido ate','Pedido ate','Pedido Ate','mv_ch4','C',6,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','05','Filial de' ,'Filial de' ,'Filial de' ,'mv_ch5','C',6,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0105','06','Filial ate','Filial ate','Filial Ate','mv_ch6','C',6,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )

*/

//
// Atualizando dicionário
//
dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aDados )
	If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

// Atualiza Helps
AtuSX1Hlp()

RestArea( aAreaDic )
RestArea( aArea )

Return NIL

Static Function AtuSX1Hlp()



Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author Júnior Conte
@since 14/12/20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
**************************
Local aRotina := {}
Local aRotFTP := {}

// Auxiliares para apresentar para usuário aviso de processamento
Local _cTestaFTP	:= ' msAguarde( { || U_XAG0105E() }, "Testando Conexão do FTP, Aguarde...") '
//Local _cEnviaFTP 	:= ' msAguarde( { || U_KEPENFTP() }, "Enviando Arquivos do FTP, Aguarde...") '




// Opções para FTP maxton
aAdd( aRotFTP, { 'Testar Conexão'   	  	, _cTestaFTP , 0, 2, 0, NIL } )



aAdd( aRotina, { 'Enviar Pedido  '   	, 'U_XAG0105A()' , 0, 2, 0, NIL } )

aAdd( aRotina, { 'FTP  maxton'		     , aRotFTP 		, 0, 2, 0, NIL } )
aAdd( aRotina, { 'Atualizar (F5)'		, 'U_XAG0105D()' , 0, 2, 0, NIL } )


Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados

@author Júnior Conte
@since 14/12/20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
*************************
Local oView
Local oModel     := FWLoadModel( 'XAG0105' )
Local oStruct    := FWFormStruct( 2, 'SC9', /*bAvalCampo*/,/*lViewUsado*/ )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'XAG0105_VIEW', oStruct, 'SC9MASTER'  )

oView:CreateHorizontalBox( 'FORMFIELD', 100 )
oView:SetOwnerView( 'XAG0105_VIEW', 'FORMFIELD' )
oView:SetDescription( 'Envio arquivo maxton' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados

@author Júnior Conte
@since 14/12/20
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
**************************
Local oModel     := NIL
Local oStruct    := NIL

oStruct := FWFormStruct( 1, 'SC9', /*bAvalCampo*/,/*lViewUsado*/ )

oModel  := MPFormModel():New( 'XAG0105M',, )
oModel:AddFields( 'SC9MASTER', NIL, oStruct,, )
oModel:SetDescription( 'Modelo de dados Envio de arquivo' )
oModel:GetModel( 'SC9MASTER' ):SetDescription( 'Envio de arquivo maxton' )

Return oModel

//testa conexao com a maxton
User Function XAG0105E()
// Diretório para geração/leiutra dos arquivos para o ERP
Local _cDirCREC := "\maxton\"//SUPERGETMV("ML_XDIRPDR",.F.,'C:\maxton\') //local padrao

// Retorno de função
Local _aRet := {.T.," "}

//Local _cDirCREC := SUPERGETMV("ML_XDIRPDR",.F.,'C:\MAXTON\') //local padrao

// Parametros para conexão do FTP Maxton
Local cFTPServ :=  SUPERGETMV("ML_XPFTPSE",.F.,"ftp.maxtonlog.com.br") // Endereço do Servidor FTP Maxton
Local nFTPPort :=  SUPERGETMV("ML_XPFTPPO",.F.,21) // Porta do Servidor FTP Maxton
Local cFTPUser :=  SUPERGETMV("ML_XPFTPUS",.F.,"agricopel") // Usuário para FTP Maxton
Local cFTPPass :=  SUPERGETMV("ML_XPFTPPA",.F.,"agri@2022") // Senha para FTP Maxton
Local cFTPDire := "/enviados/" //SUPERGETMV("ML_XPFTPDI",.F.,' ') // Diretório raiz do FTP Maxton
//Local cFTPDiBk := SUPERGETMV("ML_XPFTPDB",.F.,' ') // Diretório de backup do FTP Maxton (para arquivos processados)

// Auxiliares
Local _aArqs 	:= {}

Local i		 	:= 0
Local _cFile	:= ""

// Metodo para conectar FTP
Local _oFTP := FTPMAXTON():New()

Local _lConectou := .F.

// Auxiliares para o Log
PRIVATE cFileLog := ""
PRIVATE cPath := ""



// Conexão FTP maxton
_lConectou := _oFTP:ConectarFTP(cFTPServ,; // Endereço
					  nFTPPort,; // Porta
					  cFTPUser,; // Usuário
					  cFTPPass,; // Senha
					  ,; // Numero de tentativas
					  .T.) // Endereço é por IP?
	

// Desconecta do FTP
If _lConectou
    MsgInfo("Conexão OK.", "XAG0105E")
	_oFTP:DesconecFTP(2)
else
    sendEmail( "Erro conexão ftp Maxton", "Problema conexão FTP MaxTon, gentileza verifique  a conexão e depois gere novamente os arquivos. ")       
    MsgAlert("Problema na autenticação.", "XAG0105E")
endif 

return   _lConectou


Static Function RunCont(xFilial, xPedido, _cMark)



if __cUserID == '000000' //Se for admin deixa escolher o diretorio
    If MsgYesNo('Deseja salvar diretamente no ftp? ', 'Salvar arquivo')  
        _cPath := "\maxton\remessa\new\"
    Else   
         _cPath := cGetFile( "Arquivos de Exportacao  | ",OemToAnsi("Selecione Diretorio"), ,"" ,.T.,GETF_LOCALHARD + GETF_RETDIRECTORY)
        If alltrim(_cPath) == ''
            Return
        Endif 
    Endif
Else
    _cPath := "\maxton\remessa\new\"
	   
																																		 
Endif  





_aTotTESCFO := {}


_cQry :=  "SELECT  C9_FILIAL, C9_PEDIDO, C9_CLIENTE, C9_LOJA , C9_XHREDI, C9_DATALIB, SUM(C9_QTDLIB) C9_QTDLIB , SUM(C9_PRCVEN) C9_PRCVEN  "
_cQry := _cQry + "FROM " + RETSQLNAME("SC9") + " C9 "
_cQry := _cQry + " INNER JOIN " + RETSQLNAME("SA1") + " (NOLOCK) A1 ON A1.A1_FILIAL = '"+xFilial("SA1")+"'  "
_cQry := _cQry + "      AND  A1.A1_COD = C9.C9_CLIENTE AND A1.A1_LOJA = C9.C9_LOJA "
_cQry := _cQry + " INNER JOIN " + RETSQLNAME("SC6") + "(NOLOCK) C6 ON C6.C6_FILIAL = C9.C9_FILIAL   "
_cQry := _cQry + "      AND  C6.C6_CLI = C9.C9_CLIENTE AND C6.C6_LOJA = C9.C9_LOJA   AND C6.C6_NUM = C9.C9_PEDIDO  AND C6.C6_PRODUTO = C9.C9_PRODUTO  AND C6.C6_ITEM = C9.C9_ITEM"
_cQry := _cQry + " INNER JOIN " + RETSQLNAME("SB1") + "(NOLOCK) B1 ON C6.C6_FILIAL = B1.B1_FILIAL   "
_cQry := _cQry + "      AND  C6.C6_PRODUTO = B1.B1_COD "
_cQry := _cQry + " WHERE    B1.D_E_L_E_T_ <> '*' AND C9.D_E_L_E_T_<> '*'   And A1.D_E_L_E_T_<> '*' And C9.C9_BLEST IN (' ', 'ZZ','10')  And C9.C9_BLCRED IN (' ', 'ZZ','10')   "
//_cQry := _cQry + " And (trim(C9_PRODUTO) NOT LIKE '%801' AND B1_TIPO = 'SH'  ) "//Não envia Granel
_cQry := _cQry +" And C9.C9_PEDIDO   = '" + xPedido + "' "
_cQry := _cQry +" And C9.C9_OK       = '" + _cMark  + "' "
//_cMark
_cQry := _cQry +" And C9_FILIAL     = '19' "
_cQry := _cQry +" Group By  C9_FILIAL, C9_PEDIDO, C9_CLIENTE, C9_LOJA,C9_XHREDI,  C9_DATALIB "

//CONOUT(_cQry)

If Select("CABEC") > 0
    dbSelectArea("CABEC")                   
    DbCloseArea()
EndIf

//* Cria a Query e da Um Apelido
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"CABEC",.F.,.T.)


dbSelectArea("CABEC")
dbGotop()

cHeader   := ""

nContador := 0
cLin      := ""  	

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt,.T.)

cArquivo := ""


WHILE CABEC->(!EOF() )  

	//IF EMPTY(ALLTRIM(CABEC->C9_XHREDI))

        if empty(cHeader)
            cHeader := "0" + TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99") + SUBSTR(DTOS(DDATABASE), 7, 2) + "/"+ SUBSTR(DTOS(DDATABASE), 5, 2)  + "/"+ SUBSTR(DTOS(DDATABASE), 1, 4)
            cHeader += TIME() + cEOL
            nContador := nContador + 1
        endif

        DbSelectArea("SA1")
        DbSetOrder(1)
        dbseek(xFilial("SA1") + CABEC->C9_CLIENTE +  CABEC->C9_LOJA  )
    
    

        //******************  REGISTRO CABEÇALHO  *************************************
        cLin := cLin + "1"  
        cLin := cLin +  TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99")    																									// 1
        cLin := cLin + "2"                        // 2
        cLin := cLin +  TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99")    
        cLin := cLin + padr(CABEC->C9_PEDIDO , 10)

        cSer := sfbusser( CABEC->C9_PEDIDO, CABEC->C9_FILIAL )
        cLin := cLin + cSer

           	
    // cLin := cLin + padr(CABEC->F2_SERIE , 2)  																							// 3
        cLin := cLin + SUBSTR(CABEC->C9_DATALIB, 7, 2) + "/"+ SUBSTR(CABEC->C9_DATALIB, 5, 2) +"/"+ SUBSTR(CABEC->C9_DATALIB, 1, 4)																							// 4
        cLin := cLin + "000000000000001000"    	
        cLin := cLin + space(18) //"000000000000000000"								// 5
    // cLin := cLin + 	STRZERO(TRANSFORM(CABEC->F2_VALBRUT , "@E 9999999.99"), 10) 	
    
    // cLin := cLin + padr(strtran(cValTochar(CABEC->C9_QTDLIB * CABEC->C9_PRCVEN), ".", ""), 17, "0")		
        cLin := cLin + padl(cValTochar(INT(( CABEC->C9_QTDLIB * CABEC->C9_PRCVEN ) * 100 )), 17, "0")																	// 6
        //cLin := cLin + padr(CABEC->D2_PEDIDO , 30)  	
        //cLin := cLin + padr(CABEC->A1_NOME   , 50) 	
        //cLin := cLin + padr(CABEC->A1_CGC    , 14) 	
        //cLin := cLin + padr(CABEC->A1_CEP    , 8) 	
        //cLin := cLin + padr(CABEC->A1_EST     , 2) 	
        //cLin := cLin + padr(CABEC->A1_MUN    , 40) 																							// 7
        //cLin := cLin + padr(CABEC->A1_BAIRRO , 30) 
        //cLin := cLin + padr(CABEC->A1_END    , 60) 
        //cLin := cLin + SPACE(10)
        //cLin := cLin + SPACE(50)
        cLin := cLin + SPACE(140)
        //cLin := cLin + padr(CABEC->A4_CGC    , 14) 
                                                                                            // 12
        cLin := cLin + cEOL
        //nContTrans:= nContTrans + 1


        nContador := nContador + 1

        


        _cQryI :=  "SELECT *  "
        _cQryI := _cQryI + "FROM " + RETSQLNAME("SC9") + " C9 "
        _cQryI := _cQryI + " INNER JOIN " + RETSQLNAME("SB1") + "(NOLOCK) B1 ON C9.C9_FILIAL = B1.B1_FILIAL   "
        _cQryI := _cQryI + "      AND  C9.C9_PRODUTO = B1.B1_COD "
        _cQryI := _cQryI + " WHERE B1.D_E_L_E_T_ <> '*' AND C9.C9_FILIAL = '"+CABEC->C9_FILIAL+"'     And C9.C9_BLEST IN (' ', 'ZZ','10')  And C9.C9_BLCRED IN (' ', 'ZZ','10')  "
        _cQryI := _cQryI +"  And C9.D_E_L_E_T_<> '*' And C9_PEDIDO = '"+CABEC->C9_PEDIDO+"'  "//And C9_LOCAL   = '01'   "
        _cQryI := _cQryI +"  And C9.C9_OK = '"+_cMark+"' "
        //_cQryI := _cQryI +"  And (trim(C9_PRODUTO) NOT LIKE '%801' AND B1_TIPO = 'SH'  ) "//Não envia Granel
        
        If Select("ITEM") > 0
            dbSelectArea("ITEM")                   
            DbCloseArea()
        EndIf

        //* Cria a Query e da Um Apelido
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryI),"ITEM",.F.,.T.)


        dbSelectArea("ITEM")
        dbGotop()
            
        WHILE ITEM->(!EOF() )
        
            SB1->(dbSeek(xFilial("SB1")+ITEM->C9_PRODUTO ))
            cLin := cLin + "2" 
            cLin := cLin +  TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99")   
            cLin := cLin + "2"                        // 2
            cLin := cLin +  TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99")    
            cLin := cLin + padr(CABEC->C9_PEDIDO , 10)
            cLin := cLin + cSer// "PED"     	 		 						// 1
            cLin := cLin + padr(ITEM->C9_PRODUTO , 20 )					// 2
            cLin := cLin + SPACE(12)    
        // cLin := cLin + padl(strtran(cValTochar(round(ITEM->C9_PRCVEN , 2)), ".", ""), 17, "0")
            cLin := cLin + padl(cValTochar(int(ITEM->C9_PRCVEN * 100)), 17, "0")
            cLin := cLin + "000000000000001000"    	
            //cLin := cLin + padl(strtran(cValTochar(round(ITEM->C9_QTDLIB, 2)), ".", ""), 18, "0")
            cLin := cLin + padl(cValTochar(int(ITEM->C9_QTDLIB * 1000)), 18, "0")
            cLin := cLin + SPACE(20)  

            CDESCARM := POSICIONE("NNR", 1, xFilial("NNR") + ITEM->C9_LOCAL, "NNR_DESCRI" )

            IF alltrim(ITEM->C9_LOCAL) == '20' .OR. alltrim(ITEM->C9_LOCAL) == '27' //ALLTRIM(CDESCARM) == "ALVORADA"
                cLin := cLin + PADR( 'Z080' , 20)
            ELSEIF alltrim(ITEM->C9_LOCAL) == '01' //ALLTRIM(CDESCARM) ==  "ARMAZEM 01 LUBS" 
                cLin := cLin + PADR( 'Z030', 20)
            ELSE
                cLin := cLin + PADR( SUBSTR( alltrim(ITEM->C9_LOCAL)+''+alltrim(CDESCARM)  , 1, 20), 20)
            ENDIF

            cLin := cLin + "N"  
            
        
            //cLin := cLin + left("00"+SB1->B1_POSIPI+"0000000000",10)			// 7
            //cLin := cLin + strzero((round(ITEM->D2_IPI,2)*100),4) 				// 8
            //cLin := cLin + 	STRZERO(TRANSFORM(CABEC->D2_PRCVEN , "@E 9999999.99"), 10) 	
            
            //cLin := cLin + strzero((round(ITEM->D2_QUANT,2)*100),9)				// 10
            //cLin := cLin + LEFT(ITEM->D2_UM+SPACE(2),2)							// 11
            //cLin := cLin + strzero((round(ITEM->D2_QUANT,2)*100),9)				// 12
            //cLin := cLin + LEFT(ITEM->D2_UM+SPACE(2),2)							// 13
        //	cLin := cLin + "P"													// 14
            //cLin := cLin + strzero((round(ITEM->D2_DESC,2)*100),4)		  		// 15
            //cLin := cLin + strzero((round(ITEM->D2_TOTAL,2)*100),11) 			// 16
            //cLin := cLin + SPACE(04)											// 17
            //cLin := cLin + SPACE(01)                                        	// 18
            cLin := cLin + cEOL                                             	// 19

        

            nContador := nContador + 1


            DbSelectArea("SC6")
            DbSetOrder(1)
                                                                                                                                
            if  DbSeek( ITEM->C9_FILIAL +  ITEM->C9_PEDIDO + ITEM->C9_ITEM + ITEM->C9_PRODUTO)
                RecLock("SC6", .F.)
                    SC6->C6_XDTEDI :=  DDATABASE
                    SC6->C6_XHREDI :=  SUBSTR( TIME(), 1,5)
                MsUnlock()
            endif

            if empty(cArquivo)

                nDia := STRZERO(DAY( DATE() ) , 2)
                cMes := ""
                DO CASE

                    CASE MONTH(DATE()) == 1
                        cMes := "A"
                    CASE MONTH(DATE()) == 2
                        cMes := "B"
                    CASE MONTH(DATE()) == 3
                        cMes := "C"
                    CASE MONTH(DATE()) == 4
                        cMes := "D"
                    CASE MONTH(DATE()) == 5
                        cMes := "E"
                    CASE MONTH(DATE()) == 6
                        cMes := "F"
                    CASE MONTH(DATE()) == 7
                        cMes := "G"
                    CASE MONTH(DATE()) == 8
                        cMes := "H"
                    CASE MONTH(DATE()) == 9
                        cMes := "I"
                    CASE MONTH(DATE()) == 10
                        cMes := "J"
                    CASE MONTH(DATE()) == 11
                        cMes := "K"
                    CASE MONTH(DATE()) == 12
                        cMes := "L"

                ENDCASE


                cDtAtu := GetMV("AG_DTMAXTO")

                cSeq   := GetMV("AG_SEQ")

                if alltrim(dtos(ddatabase)) >  alltrim(cDtAtu)
                    PutMv("AG_DTMAXTO",DTOS(dDatabase))
                    PutMv("AG_SEQ","001")
                    cSeq   := GetMV("AG_SEQ")
         
                else
                    cSeq := soma1(cSeq)
                    PutMv("AG_SEQ",cSeq)

                endif


                cAno    := substr( dtos(DDATABASE), 3, 2)

                cArquivo := "AG"+ "S" + nDia + cMes + cAno +"."+alltrim(cSeq)
                //nHdl    := fCreate(TRIM(_cPath)+ "AG"+ "S" + nDia + cMes + cAno +"."+alltrim(cSeq))

            endif 

            DbSelectArea("SC9")
            DbSetOrder(1)
                                                                                                                                                                                                                            
            if  DbSeek( ITEM->C9_FILIAL +  ITEM->C9_PEDIDO + ITEM->C9_ITEM + ITEM->C9_SEQUEN  + ITEM->C9_PRODUTO)
                RecLock("SC9", .F.)
                    SC9->C9_XDTEDI  :=  DDATABASE
                    SC9->C9_XHREDI  :=  SUBSTR( TIME(), 1,5)
                    SC9->C9_XSREDI := cSer
                    SC9->C9_XARQEDI := cArquivo
                    SC9->C9_OK := SPACE(4)
                MsUnlock()
            endif

            dbSelectArea("ITEM")
            ITEM->(DbSkip())       

        EndDo
   // ENDIF



    dbSelectArea("CABEC")
	CABEC->(DbSkip())       

ENDDO
    IF !EMPTY(cLin)
        cLin := cLin + "9" + padl(cValTochar( nContador + 1), 5, "0")  +  cEOL 

        cLin := cHeader + cLin
        /*
        nDia := STRZERO(DAY( DATE() ) , 2)
        cMes := ""
        DO CASE

            CASE MONTH(DATE()) == 1
                cMes := "A"
            CASE MONTH(DATE()) == 2
                cMes := "B"
            CASE MONTH(DATE()) == 3
                cMes := "C"
            CASE MONTH(DATE()) == 4
                cMes := "D"
            CASE MONTH(DATE()) == 5
                cMes := "E"
            CASE MONTH(DATE()) == 6
                cMes := "F"
            CASE MONTH(DATE()) == 7
                cMes := "G"
            CASE MONTH(DATE()) == 8
                cMes := "H"
            CASE MONTH(DATE()) == 9
                cMes := "I"
            CASE MONTH(DATE()) == 10
                cMes := "J"
            CASE MONTH(DATE()) == 11
                cMes := "K"
            CASE MONTH(DATE()) == 12
                cMes := "L"

        ENDCASE


        cDtAtu := GetMV("AG_DTMAXTO")

        cSeq   := GetMV("AG_SEQ")

        if alltrim(dtos(ddatabase)) >  alltrim(cDtAtu)
            PutMv("AG_DTMAXTO",DTOS(dDatabase))
            PutMv("AG_SEQ","001")
            cSeq   := GetMV("AG_SEQ")
    // endif

    //  if alltrim(dtos(ddatabase)) ==  alltrim(cDtAtu)
        else
            cSeq := soma1(cSeq)
            PutMv("AG_SEQ",cSeq)

        endif

        //AG_DTMAXTO

        //AG_SEQ    

        cAno    := substr( dtos(DDATABASE), 3, 2)

        */
      //  nHdl    := fCreate(TRIM(_cPath)+ "AG"+ "S" + nDia + cMes + cAno +"."+alltrim(cSeq))
        
         nHdl    := fCreate( TRIM(_cPath)+ cArquivo )
        
        //alert(nHdl)

    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
        //³ linha montada.                                                      ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
            //If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
                //Exit
            //ndif
        else
        // MsgInfo("Criado arquivo " +TRIM(_cPath)+ ALLTRIM(CABEC->D2_PEDIDO) +".TXT"  , "Corpem")
        endif

        fClose(nHdl)

        lret := .T. 
    else
        
         lret := .F. 
    
    endif


    U_XAG0099(.T.)
     

Return  lret




static function sfbusser(xPedido, xfilial)

Local cMaxSerie := ""

cSer := "PED"

_cQry :=  " SELECT DISTINCT  C9_XSREDI  "
_cQry := _cQry + "FROM " + RETSQLNAME("SC9") + " C9 "
_cQry := _cQry + " WHERE   "//C9.D_E_L_E_T_<> '*'   AND   "
_cQry := _cQry + "  C9.C9_PEDIDO =  '"+xPedido+"' "
_cQry := _cQry + " AND C9.C9_FILIAL =  '"+xfilial+"' "
_cQry := _cQry + " AND C9.C9_XSREDI <> ' ' "


//CONOUT(_cQry)

If Select("CABEC1") > 0
    dbSelectArea("CABEC1")                   
    DbCloseArea()
EndIf

//* Cria a Query e da Um Apelido
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"CABEC1",.F.,.T.)


dbSelectArea("CABEC1")
dbGotop()

aSer := {}

WHILE CABEC1->(!EOF() )  
   
    aadd(aSer, CABEC1->C9_XSREDI )
  
    //Captura a maior serie gerada até aqui
    If CABEC1->C9_XSREDI <> 'PED'
        If CABEC1->C9_XSREDI > cMaxSerie 
            cMaxSerie := CABEC1->C9_XSREDI
        Endif 
    Endif 
    CABEC1->(DBSKIP() ) 
ENDDO

If len(aSer) >= 1 
    cser := strzero(len(aser),3)
Endif 

/*
If len(aSer) >= 1 
cser := '001'
elseif len(aSer) == 2
cser := '002'
elseif len(aSer) == 3
cser := '003'
elseif len(aSer) == 4
cser := '004'
elseif len(aSer) == 5
cser := '005'
elseif len(aSer) == 6
cser := '006'
elseif len(aSer) == 7
cser := '007'
elseif len(aSer) == 8
cser := '008'
elseif len(aSer) == 9
cser := '009'
elseif len(aSer) == 10
cser := '010'
endif*/

//Serie escolhida tem que ser maior que a Maior serie encontrada
If cMaxSerie <> '' .and. cser <= cMaxSerie
    cSer := SOMA1(cMaxSerie)
Endif 


return cser


//função para enviar email quando houver falha na conexao com FTP.
Static Function sendEmail( _cSubject, _cTexto)
		_cTo := SuperGetMV("MV_XERRFTP",.F.,"suporte.sistemas@agricopel.com.br")
 		oProcess := TWFProcess():New("WORKFLOW", "NOTIFICA")
        oProcess:NewTask("NOTIFICA",'\workflow\WFERROFTP.htm')
        oHtml     := oProcess:oHtml
        oHtml:ValByName("Titulo", "Workflow de Notificação (" + DTOC(Date()) + " - " + Time() + ")")

        oHtml:ValByName( "MENSAGEM"	, "Integração Protheus x Maxton")


        oHtml:ValByName( "TEXTO", _cTexto + "<br>" )

        oProcess:ClientName(cUserName)
        oProcess:cTo := _cTo 
        oProcess:cSubject := "Workflow de Notificação - Falha Conexão FTP MaxTon (" + DTOC(Date()) + " - " + Time() + ")"
        oProcess:Start()
        oProcess:Free()
Return																  

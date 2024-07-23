#include "rwmake.ch"
#include "topconn.ch"
#Include "protheus.ch"


/*
+------------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                        !
+------------------------------------------------------------------------------+
!                                 DADOS DO PROGRAMA                            !
+------------------+-----------------------------------------------------------+
!Tipo              ! Relat�rio                                                 !
+------------------+-----------------------------------------------------------+
!M�dulo            ! Configurador                                              !
+------------------+-----------------------------------------------------------+
!Nome              ! U_CFGUSR()                                                !
+------------------+-----------------------------------------------------------+
!Descricao         ! Relat�rio de usu�rios 				                       !
+------------------+-----------------------------------------------------------+
!Autor             ! Thiago Leonardo de Almeida                                !
+------------------+-----------------------------------------------------------+
!Data de Criacao   ! 16/07/2015                        			               !
+------------------+-----------------------------------------------------------+
!   ATUALIZACOES                                                               !
+-------------------------------------------+-----------+-----------+----------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  ! Data da  !
!                                           !Solicitante! Respons.  ! Atualiz. !
+-------------------------------------------+-----------+-----------+----------+
!                                           !           !           !          !
!                                           !           !           !          !
+-------------------------------------------+-----------+-----------+----------+*/

User Function CFGUSR() // U_CFGUSR()

IF MSGYESNO('Deseja realizar a busca de usu�rios?','Busca de usu�rios')
	MsgRun("Buscando...","Busca de Usuarios",{|| U_BSCUSER()})
ENDIF

Return

User Function BSCUSER()

Local nI
Local nE
Local cResult
Local oExcel
Local cLib		:= ''
Local cEmp		:= ''
Local _cDlocal	:= 'C:\TEMP'
Local aDirL		:= Directory(_cDlocal,"D") 
Local cImp 
Local aRet

Private cNmodulo
Private cNumMod

IF Len(aDirL) = 0
	Makedir("C:\TEMP")   // cria a pasta na Esta��o se n�o existir
ELSE
	FErase("C:\TEMP\users.csv")  // apaga o arquivo existente
ENDIF

cResult	:= FCreate("C:\TEMP\users.csv")  // cria o arquivo de trabalho

If cResult == -1 // valida a cria��o do arquivo
	MsgAlert("N�o foi poss�vel gerar o arquivo C:\TEMP\users.csv"+Chr(13) + Chr(10)+"Verifique se o arquivo n�o est� aberto","Busca de usu�rios")
	Return
EndIf

IF MSGNOYES('Deseja listar os usu�rios Bloqueados?','Busca de usu�rios')
	FWrite(cResult,"User_ID;Login do Usuario;Nome do Usuario;Dt Validade;Acesso;Acessos Simult�neos;e-mail;Empresas;Departamento;Cargo;Amb.Impress�o"+Chr(13) + Chr(10)) //Cabe�alho
	aRet := AllUsers()
	For nI := 1 to Len(aRet)
		IF !aRet[nI][1][17]  		// |-> Verifica se o usu�rio est� liberado
			cLib	:= 'Liberado'	// |
		else						// |
			cLib 	:= "BLOQUEADO"	// |
		endif						//_|
		cEmp := ''
		For nE := 1 to LEN(aRet[nI][2][6])   		// |-> Busca o acesso as empresas
			IF '@' $ (aRet[nI][2][6][nE]) 			// |
				cEmp	+= 'Todas'					// |
			ELSE									// |
				cEmp	+= aRet[nI][2][6][nE]+' '	// |
			ENDIF									// |
		Next                                        //_|
			IF aRet[nI][2][10]	= 1	  		// |-> Trata a exibi��o do ambiente de Impress�o
				cImp	:= 'SERVIDOR'		// |
			ELSEIF aRet[nI][2][10]	= 0		// |
				cImp	:= 'SERVIDOR'		// |
			ELSEIF aRet[nI][2][10]	= 2		// |
				cImp	:= 'Local'			// |
			ENDIF							//_|
  
		FWrite(cResult,aRet[nI][1][1] + ";" + aRet[nI][1][2] + ";" + aRet[nI][1][4] + ";" + DTOC(aRet[nI][1][6]) + ";" + cLib + ";" + ALLTRIM(STR(aRet[nI][1][15]))+ ";" +;
		aRet[nI][1][14] + ";" + cEmp + ";" + aRet[nI][1][12] + ";" + aRet[nI][1][13] + ";" + cImp + ";" + Chr(13) + Chr(10))
	Next
ELSE  						// Lista apenas os usu�rios liberados  
	FWrite(cResult,"User_ID;Login do Usuario;Nome do Usuario;Dt Validade;Acessos Simult�neos;e-mail;empresas;Departamento;Cargo;Amb.Impress�o"+Chr(13) + Chr(10)) //Cabe�alho
	aRet := AllUsers()
	For nI := 1 to Len(aRet)
		IF !aRet[nI][1][17] // Verifica se o usu�rio est� liberado
			cEmp := ''
			For nE := 1 to LEN(aRet[nI][2][6])  		// |-> Busca o acesso as empresas
				IF '@' $ (aRet[nI][2][6][nE])      		// |
					cEmp	+= 'Todas'					// |
				ELSE									// |
					cEmp	+= aRet[nI][2][6][nE]+' '	// |
				ENDIF									// |
			Next										//_|
			IF aRet[nI][2][10]	= 1	  		// |-> Trata a exibi��o do ambiente de Impress�o
				cImp	:= 'SERVIDOR'		// |
			ELSEIF aRet[nI][2][10]	= 0		// |
				cImp	:= 'SERVIDOR'		// |
			ELSEIF aRet[nI][2][10]	= 2		// |
				cImp	:= 'Local'			// |
			ENDIF							//_|
			FWrite(cResult,aRet[nI][1][1] + ";" + aRet[nI][1][2] + ";" + aRet[nI][1][4] + ";" + DTOC(aRet[nI][1][6]) + ";" + ALLTRIM(STR(aRet[nI][1][15]))+ ";" + aRet[nI][1][14] + ";" +;
			cEmp + ";" + aRet[nI][1][12] + ";" + aRet[nI][1][13] + ";" + cImp + ";" + Chr(13) + Chr(10)) //[n][2][10]
			FWrite(cResult,"N�;M�dulo;Menu" + Chr(13) + Chr(10))
			FOR nm :=1 to Len(aRet[nI][3])
				IF SUBSTR(aRet[nI][3][nm],3,1) <> "X" 
					cNumMod  := SUBSTR(aRet[nI][3][nm],1,2)
					cNmodulo := u_BsModul()
//					FWrite(cResult,SUBSTR(aRet[nI][3][nm],1,2) + ";" + SUBSTR(aRet[nI][3][nm],1,3) + ";" + SUBSTR(aRet[nI][3][nm],4,30) + ";" + Chr(13) + Chr(10))
					FWrite(cResult,SUBSTR(aRet[nI][3][nm],1,2) + ";" + cNmodulo + ";" + SUBSTR(aRet[nI][3][nm],4,30) + ";" + Chr(13) + Chr(10))
				ENDIF
			NEXT 
			FWrite(cResult,Chr(13) + Chr(10))
		ENDIF
	Next
ENDIF
FClose(cResult)

IF !ApOleClient("MSExcel") 
	MsgAlert("Microsoft Excel n�o instalado!"+ Chr(13) + Chr(10)+"O arquivo gerado, n�o ser� aberto automaticamente neste computador","Busca de usu�rios")
ELSE
	oExcel := MSExcel():New()					// |-> Abre o arquivo no Excel
	oExcel:WorkBooks:Open("C:\TEMP\users.csv")	// |
	oExcel:SetVisible(.T.)						// |
	oExcel:Destroy()							//_|
ENDIF

AVISO('Arquivo gerado em:','C:\TEMP\users.csv',{'Obrigado'},3)

return

User Function BsModul()

IF cNumMod == "01"
	cNmodulo := "Ativo Fixo"
ELSEIF cNumMod == "02"	
	cNmodulo := "Compras"
ELSEIF cNumMod == "04"	
	cNmodulo := "Estoque"	
ELSEIF cNumMod == "05"	
	cNmodulo := "Faturamento"
ELSEIF cNumMod == "06"
	cNmodulo := "Financeiro"
ELSEIF cNumMod == "09"
	cNmodulo := "Livros Fiscais"
ELSEIF cNumMod == "13"
	cNmodulo := "Call Center"
ELSEIF cNumMod == "34"
	cNmodulo := "Contabilidade"
ELSEIF cNumMod == "39"
	cNmodulo := "OMS"	
ELSEIF cNumMod == "42"
	cNmodulo := "WMS"
ELSEIF cNumMod == "43"
	cNmodulo := "TMS"
ELSEIF cNumMod == "99"
	cNmodulo := "Configurador"	
ELSE
	cNmodulo := cNumMod
ENDIF

Return(cNmodulo)

/*
Instru��es do array allUsers

Sintaxe: AllUsers - Informa��es do usu�rio ( [ lSerie ] [ lAlfa ] ) --> aUsers

Retorno:
aUsers(vetor)
Array contendo as informa��es dos usu�rios.

Observa��es
lSerie 
 .T. - as informa��es de senhap ser�o retornadas.
 .F. - as informa��es de senhap n�o ser�o retornadas.
 
lAlfa
.T. - o �ndice utilizado ser� o nome do usu�rio
.F. - o �ndice utilizado ser� o c�digo do usu�rio

aUsers

[n][1][1]   C     N�mero de identifica��o seq�encial com o tamanho de 6 caracteres
[n][1][2]   C     Nome do usu�rio
[n][1][3]   C     Senha (criptografada)
[n][1][4]   C     Nome completo do usu�rio
[n][1][5]   A     Vetor contendo as �ltimas n senhas do usu�rio
[n][1][6]   D     Data de validade
[n][1][7]   N     N�mero de dias para expirar
[n][1][8]   L      Autoriza��o para alterar a senha
[n][1][9]   L      Alterar a senha no pr�ximo logon
[n][1][10]  A     Vetor com os grupos
[n][1][11]  C     N�mero de identifica��o do superior
[n][1][12]  C     Departamento
[n][1][13]  C     Cargo
[n][1][14]  C     E-mail
[n][1][15]  N     N�mero de acessos simult�neos
[n][1][16]  D     Data da �ltima altera��o
[n][1][17]  L      Usu�rio bloqueado
[n][1][18]  N     N�mero de d�gitos para o ano
[n][1][19]  L      Listner de liga��es
[n][1][20]  C     Ramal
[n][1][21]  C     Log de opera��es
[n][1][22]  C     Empresa, filial e matricula
[n][1][23]  A     Informa��es do sistema 
    [n][1][23][1]  L  Permite alterar database do sistema
    [n][1][23][1]  N  Dias a retroceder
    [n][1][23][1]  N  Dias a avan�ar
[n][1][24]  D     Data de inclus�o no sistema
[n][1][25]  C     N�vel global de campo
[n][1][26]  U     N�o usado    

[n][2][1]   A    Vetor contendo os hor�rios dos acessos. Cada elemento do vetor corresponde a um dia da semana com a hora inicial e final.
[n][2][2]   N    Uso interno
[n][2][3]   C    Caminho para impress�o em disco
[n][2][4]   C    Driver para impress�o direto na porta. Ex: EPSON.DRV
[n][2][5]   C    Acessos
[n][2][6]   A    Vetor contendo as empresas, cada elemento contem a empresa e a filial. Ex:"9901", se existir "@@@@" significa acesso a todas as empresas
[n][2][7]   C    Elemento alimentado pelo ponto de entrada USERACS
[n][2][8]   N    Tipo de impress�o: 1 - em disco, 2 - via Windows e 3 direto na porta
[n][2][9]   N    Formato da p�gina: 1 � retrato, 2 - paisagem
[n][2][10]  N    Tipo de Ambiente de Impress�o: 1 � servidor, 2 - cliente
[n][2][11]  L     Priorizar configura��o do grupo
[n][2][12]  C    Op��o de impress�o
[n][2][13]  L    Acessar outros diret�rios de impress�o

[n][3]      A    Vetor contendo o m�dulo, o n�vel e o menu do usu�rio. 
      Ex: [n][3][1] = "019\sigaadv\sigaatf.xnu"
            [n][3][2] = "029\sigaadv\sigacom.xnu"

Se o par�metro lSerie for igual a .T., a dimens�o 4 do array tamb�m ser� mostrada.

[n][4]       A    Vetor contendo as informa��es do SenhaP
[n][4][1]  L     Utiliza SenhaP
[n][4][2]  C    N�mero de s�rie do SenhaP
[n][4][3]  C    N�o usado
[n][4][4]  C    N�o usado

[n][5]       A    Array com as informa��es do painel de gest�o
[n][6]       A    Array com as informa��es dos indicadores nativos
*/
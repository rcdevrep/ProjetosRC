#include "rwmake.ch"
#include "topconn.ch"
#Include "protheus.ch"


/*
+------------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                        !
+------------------------------------------------------------------------------+
!                                 DADOS DO PROGRAMA                            !
+------------------+-----------------------------------------------------------+
!Tipo              ! Relatório                                                 !
+------------------+-----------------------------------------------------------+
!Módulo            ! Configurador                                              !
+------------------+-----------------------------------------------------------+
!Nome              ! U_CFGUSR()                                                !
+------------------+-----------------------------------------------------------+
!Descricao         ! Relatório de usuários 				                       !
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

IF MSGYESNO('Deseja realizar a busca de usuários?','Busca de usuários')
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
	Makedir("C:\TEMP")   // cria a pasta na Estação se não existir
ELSE
	FErase("C:\TEMP\users.csv")  // apaga o arquivo existente
ENDIF

cResult	:= FCreate("C:\TEMP\users.csv")  // cria o arquivo de trabalho

If cResult == -1 // valida a criação do arquivo
	MsgAlert("Não foi possível gerar o arquivo C:\TEMP\users.csv"+Chr(13) + Chr(10)+"Verifique se o arquivo não está aberto","Busca de usuários")
	Return
EndIf

IF MSGNOYES('Deseja listar os usuários Bloqueados?','Busca de usuários')
	FWrite(cResult,"User_ID;Login do Usuario;Nome do Usuario;Dt Validade;Acesso;Acessos Simultâneos;e-mail;Empresas;Departamento;Cargo;Amb.Impressão"+Chr(13) + Chr(10)) //Cabeçalho
	aRet := AllUsers()
	For nI := 1 to Len(aRet)
		IF !aRet[nI][1][17]  		// |-> Verifica se o usuário está liberado
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
			IF aRet[nI][2][10]	= 1	  		// |-> Trata a exibição do ambiente de Impressão
				cImp	:= 'SERVIDOR'		// |
			ELSEIF aRet[nI][2][10]	= 0		// |
				cImp	:= 'SERVIDOR'		// |
			ELSEIF aRet[nI][2][10]	= 2		// |
				cImp	:= 'Local'			// |
			ENDIF							//_|
  
		FWrite(cResult,aRet[nI][1][1] + ";" + aRet[nI][1][2] + ";" + aRet[nI][1][4] + ";" + DTOC(aRet[nI][1][6]) + ";" + cLib + ";" + ALLTRIM(STR(aRet[nI][1][15]))+ ";" +;
		aRet[nI][1][14] + ";" + cEmp + ";" + aRet[nI][1][12] + ";" + aRet[nI][1][13] + ";" + cImp + ";" + Chr(13) + Chr(10))
	Next
ELSE  						// Lista apenas os usuários liberados  
	FWrite(cResult,"User_ID;Login do Usuario;Nome do Usuario;Dt Validade;Acessos Simultâneos;e-mail;empresas;Departamento;Cargo;Amb.Impressão"+Chr(13) + Chr(10)) //Cabeçalho
	aRet := AllUsers()
	For nI := 1 to Len(aRet)
		IF !aRet[nI][1][17] // Verifica se o usuário está liberado
			cEmp := ''
			For nE := 1 to LEN(aRet[nI][2][6])  		// |-> Busca o acesso as empresas
				IF '@' $ (aRet[nI][2][6][nE])      		// |
					cEmp	+= 'Todas'					// |
				ELSE									// |
					cEmp	+= aRet[nI][2][6][nE]+' '	// |
				ENDIF									// |
			Next										//_|
			IF aRet[nI][2][10]	= 1	  		// |-> Trata a exibição do ambiente de Impressão
				cImp	:= 'SERVIDOR'		// |
			ELSEIF aRet[nI][2][10]	= 0		// |
				cImp	:= 'SERVIDOR'		// |
			ELSEIF aRet[nI][2][10]	= 2		// |
				cImp	:= 'Local'			// |
			ENDIF							//_|
			FWrite(cResult,aRet[nI][1][1] + ";" + aRet[nI][1][2] + ";" + aRet[nI][1][4] + ";" + DTOC(aRet[nI][1][6]) + ";" + ALLTRIM(STR(aRet[nI][1][15]))+ ";" + aRet[nI][1][14] + ";" +;
			cEmp + ";" + aRet[nI][1][12] + ";" + aRet[nI][1][13] + ";" + cImp + ";" + Chr(13) + Chr(10)) //[n][2][10]
			FWrite(cResult,"Nº;Módulo;Menu" + Chr(13) + Chr(10))
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
	MsgAlert("Microsoft Excel não instalado!"+ Chr(13) + Chr(10)+"O arquivo gerado, não será aberto automaticamente neste computador","Busca de usuários")
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
Instruções do array allUsers

Sintaxe: AllUsers - Informações do usuário ( [ lSerie ] [ lAlfa ] ) --> aUsers

Retorno:
aUsers(vetor)
Array contendo as informações dos usuários.

Observações
lSerie 
 .T. - as informações de senhap serão retornadas.
 .F. - as informações de senhap não serão retornadas.
 
lAlfa
.T. - o índice utilizado será o nome do usuário
.F. - o índice utilizado será o código do usuário

aUsers

[n][1][1]   C     Número de identificação seqüencial com o tamanho de 6 caracteres
[n][1][2]   C     Nome do usuário
[n][1][3]   C     Senha (criptografada)
[n][1][4]   C     Nome completo do usuário
[n][1][5]   A     Vetor contendo as últimas n senhas do usuário
[n][1][6]   D     Data de validade
[n][1][7]   N     Número de dias para expirar
[n][1][8]   L      Autorização para alterar a senha
[n][1][9]   L      Alterar a senha no próximo logon
[n][1][10]  A     Vetor com os grupos
[n][1][11]  C     Número de identificação do superior
[n][1][12]  C     Departamento
[n][1][13]  C     Cargo
[n][1][14]  C     E-mail
[n][1][15]  N     Número de acessos simultâneos
[n][1][16]  D     Data da última alteração
[n][1][17]  L      Usuário bloqueado
[n][1][18]  N     Número de dígitos para o ano
[n][1][19]  L      Listner de ligações
[n][1][20]  C     Ramal
[n][1][21]  C     Log de operações
[n][1][22]  C     Empresa, filial e matricula
[n][1][23]  A     Informações do sistema 
    [n][1][23][1]  L  Permite alterar database do sistema
    [n][1][23][1]  N  Dias a retroceder
    [n][1][23][1]  N  Dias a avançar
[n][1][24]  D     Data de inclusão no sistema
[n][1][25]  C     Nível global de campo
[n][1][26]  U     Não usado    

[n][2][1]   A    Vetor contendo os horários dos acessos. Cada elemento do vetor corresponde a um dia da semana com a hora inicial e final.
[n][2][2]   N    Uso interno
[n][2][3]   C    Caminho para impressão em disco
[n][2][4]   C    Driver para impressão direto na porta. Ex: EPSON.DRV
[n][2][5]   C    Acessos
[n][2][6]   A    Vetor contendo as empresas, cada elemento contem a empresa e a filial. Ex:"9901", se existir "@@@@" significa acesso a todas as empresas
[n][2][7]   C    Elemento alimentado pelo ponto de entrada USERACS
[n][2][8]   N    Tipo de impressão: 1 - em disco, 2 - via Windows e 3 direto na porta
[n][2][9]   N    Formato da página: 1 – retrato, 2 - paisagem
[n][2][10]  N    Tipo de Ambiente de Impressão: 1 – servidor, 2 - cliente
[n][2][11]  L     Priorizar configuração do grupo
[n][2][12]  C    Opção de impressão
[n][2][13]  L    Acessar outros diretórios de impressão

[n][3]      A    Vetor contendo o módulo, o nível e o menu do usuário. 
      Ex: [n][3][1] = "019\sigaadv\sigaatf.xnu"
            [n][3][2] = "029\sigaadv\sigacom.xnu"

Se o parâmetro lSerie for igual a .T., a dimensão 4 do array também será mostrada.

[n][4]       A    Vetor contendo as informações do SenhaP
[n][4][1]  L     Utiliza SenhaP
[n][4][2]  C    Número de série do SenhaP
[n][4][3]  C    Não usado
[n][4][4]  C    Não usado

[n][5]       A    Array com as informações do painel de gestão
[n][6]       A    Array com as informações dos indicadores nativos
*/
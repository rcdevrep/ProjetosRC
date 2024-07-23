#Include "PROTHEUS.CH" 
#Include "RWMAKE.CH"                       

//---------------------------------------------//
//    Função:A010TOK                           //
//    Utilização: Valida Endereço              //
//    Data: 30/09/2015                         //
//    Autor: Leandro Spiller                   //                               
//---------------------------------------------//
User Function A010TOK()

	Local cNfolder

	//Chamado 61781 - Exigir campos ANP quando Lub/Comb.
	If SB1->(FieldPos("B1_CODSIMP")) > 0 .and. SB1->(FieldPos("B1_VOLSIMP")) > 0 
		If alltrim(M->B1_TIPO) $ 'LU/CO' .and. (Empty(M->B1_CODSIMP) .OR. Empty(M->B1_VOLSIMP) )
			Alert('Obrigatório preenchimento de Codigo SIMP/ANP e Volume para Lubrificantes/Combustiveis!')
			Return .F.
		Endif
	Endif


	If alltrim(M->B1_XRUA) <> '' .AND. (INCLUI .or. ALTERA)
		DbSelectarea('Z03') 
		DbSetOrder(1) 
		If !(DbSeek(xFilial('Z03')+alltrim(M->B1_XRUA)+alltrim(M->B1_XBLOCO)+alltrim(M->B1_XNIVEL)+alltrim(M->B1_XAPTO)))
		   //	alert('Endereço inválido, por favor verifique!')    
			alert('Endereço inválido, verifique na aba Endereçamento o endereço 1: '+alltrim(M->B1_XRUA)+alltrim(M->B1_XBLOCO)+alltrim(M->B1_XNIVEL)+alltrim(M->B1_XAPTO) ) 
			Return .F.	
		Endif
	Endif
	
	If alltrim(M->B1_XLOCAL2) <> '' .AND. (INCLUI .or. ALTERA)
		DbSelectarea('Z03') 
		DbSetOrder(1) 
		If !(DbSeek(xFilial('Z03')+M->B1_XLOCAL2))
		   	alert('Endereço inválido, verifique na aba Endereçamento o endereço 2: '+M->B1_XLOCAL2)
			Return .F.	
		Endif

	Endif
	
	If alltrim(M->B1_XLOCAL3) <> '' .AND. (INCLUI .or. ALTERA)
	
		DbSelectarea('Z03') 
		DbSetOrder(1) 
		If !(DbSeek(xFilial('Z03')+M->B1_XLOCAL3))
			alert('Endereço inválido, verifique na aba Endereçamento o endereço 3: '+M->B1_XLOCAL3)		   
			Return .F.	
		Endif
	
	Endif
// Validação para obrigatoriedade de preenchimento do campo B1_TROCA, para a filial 06, solicitado pelo Marcio - Thiago SLA - 24/05/2016
	IF cEmpAnt == '01' .AND. cFilAnt == '06' .AND. (INCLUI .or. ALTERA)
		IF EMPTY(M->B1_TROCA)
			cNfolder := POSICIONE("SX3",2,"B1_TROCA","X3_FOLDER")
			cNfolder := BsPasta(cNfolder)
			MSGALERT("Preencha o campo Troca(B1_TROCA), na "+cNfolder+".","A010TOK - ATENÇÃO")
			Return .F.	
		ENDIF

		IF alltrim(M->B1_LOCPAD) == '02' .and. EMPTY(M->B1_TIPCAR)
			cNfolder := POSICIONE("SX3",2,"B1_TIPCAR","X3_FOLDER")
			cNfolder := BsPasta(cNfolder)
			MSGALERT("Preencha o campo Tipo Carga(B1_TIPCAR), na "+cNfolder+".","A010TOK - ATENÇÃO")
			Return .F.	
		ENDIF		
	ENDIF
	
Return .T.	

// Função para busca do nome da pasta
Static Function BsPasta(cNfolder)

	IF EMPTY(cNfolder)
		cNfolder := "pasta Outros"
	ELSE 
		cNfolder := "pasta "+(POSICIONE("SXA",1,"SA1"+cNfolder,"XA_DESCRIC"))
	ENDIF

Return(cNfolder)
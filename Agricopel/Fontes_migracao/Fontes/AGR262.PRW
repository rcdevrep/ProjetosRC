#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 06/11/01
#INCLUDE "topconn.ch"

User Function AGR262()        // incluido pelo assistente de conversao do AP5 IDE em 06/11/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,NUSADO,AHEADER,ACOLS,_NPOSFOR,_NPOSGRU")
SetPrvt("_NPOSCOMP,_NPOSLARG,_NPOSQTDE,_NPOSFP,_NPOSENT,_NPOSDEL")
SetPrvt("CTIPOENT,DDATA,NLINGETD,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,LRETMOD2,NIT,xTotCheque,cTotCheque,cMens,nTotCli,nTotMun")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracoes de arrays                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Select("AGR262") <> 0)
	dbSelectArea("AGR262")
	dbCloseArea()
	If File("AGR262"+OrdBagExt())
		FErase("AGR262"+OrdBagExt())
	Endif
Endif
aStru:={}
aadd(aStru,{'COD'    ,'C',06,0})
aadd(aStru,{'LOJA'   ,'C',02,0})
aadd(aStru,{'VEND'   ,'C',06,0})
aadd(aStru,{'VEND2'  ,'C',06,0})
aadd(aStru,{'VENDN'  ,'C',06,0})
aadd(aStru,{'VENDN2' ,'C',06,0})
cArq :=CriaTrab(aStru,.t.)
use &cArq alias AGR262 new
Index on COD+LOJA to AGR2621

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcao de acesso para o Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza
nOpcx := 3
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aHeader                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(DbSetOrder(1))               // filial+cliente+loja
dbSelectArea("Sx3")
dbSetOrder(1)
dbSeek("SA1")
nUsado  := 0
aHeader := {}
While !Eof() .And. (x3_arquivo == "SA1")
           If Upper(AllTrim(X3_CAMPO)) == "A1_MUNE" .or.;
              Upper(AllTrim(X3_CAMPO)) == "A1_MUNC" 
              dbSkip()
              Loop
           Endif
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
           If Upper(AllTrim(X3_CAMPO)) <> "A1_MUN" 
              dbSkip()
              Loop
           Endif
           nUsado := nUsado + 1
           AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
                x3_tamanho, x3_decimal,"",;
                x3_usado, x3_tipo, x3_arquivo, x3_context } )
   Endif
   dbSkip()
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aCols                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols  := Array(1,nUsado+1)    
dbSelectArea("Sx3")
dbSeek("SA1")
nUsado := 0
While !Eof() .And. (x3_arquivo == "SA1")
           If Upper(AllTrim(X3_CAMPO)) == "A1_MUNE" .or.;
              Upper(AllTrim(X3_CAMPO)) == "A1_MUNC" 
              dbSkip()
              Loop
           Endif
           If Upper(AllTrim(X3_CAMPO)) <> "A1_MUN" 
              dbSkip()
              Loop
           Endif
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
           nUsado := nUsado + 1  
           IF nOpcx == 3
              IF x3_tipo == "C"
                 aCOLS[1][nUsado] := SPACE(x3_tamanho)
              Elseif x3_tipo == "N"
                 aCOLS[1][nUsado] := 0
              Elseif x3_tipo == "D"
                 aCOLS[1][nUsado] := CTOD('  /  /  ')
              Elseif x3_tipo == "M"
                 aCOLS[1][nUsado] := ""
              Else
                 aCOLS[1][nUsado] := .F.
              Endif
           Endif
        Endif
   dbSkip()
End

aCOLS[1][nUsado+1] := .F. 

_nPosMun  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="A1_MUN" })
//_nPosTipo := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_TIPO"    })
//_nPosBanc := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_BANCO"   })
//_nPosAgen := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_AGENCIA" })
//_nPosCont := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_CONTA"   })
//_nPosNum  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_NUM"     })
//_nPosVenc := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_VENCTO"  })
//_nPosValo := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_VALOR"   })
//_nPosCMC7 := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_CMC7"    })

_nPosDel  := Len(aHeader) + 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Cabecalho do Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//dData    := ddatabase
cVend   := Space(6)
cVend2  := Space(6)
cVendN  := Space(6)
cVendN2 := Space(6)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Rodape do Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinGetD := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo da Janela                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo := "Atualiza Cliente x Vendedor (Televendas e Lubrif.)"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aC := {}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
#IFDEF WINDOWS
//        AADD(aC,{"cTipoent"        ,{15,10} ,"Tipo" ,"@!",,,})
//        AADD(aC,{"dData"        ,{15,200} ,"Data",    ,,,})
        AADD(aC,{"cVend"      ,{17,050} ,"De: Televen","@!","Vazio() .or. existcpo('SA3')","SA3",})
        AADD(aC,{"cVend2"     ,{17,150} ,"De: Lubrifi","@!","Vazio() .or. existcpo('SA3')","SA3",})
        AADD(aC,{"cVendN"     ,{17,300} ,"Para: Televen","@!","Vazio() .or. existcpo('SA3')","SA3",})
        AADD(aC,{"cVendN2"    ,{17,400} ,"Para: Lubrifi","@!","Vazio() .or. existcpo('SA3')","SA3",})
#ELSE
//        AADD(aC,{"cTipoent"     ,{6,5} ,"Tipo"       ,"@!"                   ,,,})
//        AADD(aC,{"dData"     ,{6,40} ,"Data"      ,   ,,,})
        AADD(aC,{"cVend"      ,{17,050} ,"De: Televen","@!","Vazio() .or. existcpo('SA3')","SA3",})
        AADD(aC,{"cVend2"     ,{17,150} ,"De: Lubrifi","@!","Vazio() .or. existcpo('SA3')","SA3",})
        AADD(aC,{"cVendN"     ,{17,300} ,"Para: Televen","@!","Vazio() .or. existcpo('SA3')","SA3",})
        AADD(aC,{"cVendN2"    ,{17,400} ,"Para: Lubrifi","@!","Vazio() .or. existcpo('SA3')","SA3",})
#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Rodape do Modelo 2         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aR := {}
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com coordenadas da GetDados no modelo2                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF WINDOWS
        aCGD := {42,5,123,315}
#ELSE
        aCGD := {08,04,20,73}
#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes na GetDados da Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cLinhaOk := "ExecBlock('Md2LinOk',.f.,.f.)"
//cTudoOk  := "ExecBlock('Md2TudOk',.f.,.f.)"
cLinhaOk := "AllwaysTrue()" 
cTudoOk  := "AllwaysTrue()"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Modelo2                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// lRetMod2 = .t. se confirmou 
// lRetMod2 = .f. se cancelou

//ExecBlock('AGRXXX',.f.,.f.)

lRetMod2   := .t.

nTotCli    := 0
nTotMun    := 0

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente

While lRetMod2

   lRetMod2 := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

   If lRetMod2
   
		nTotCli    := 0
		nTotMun    := 0
		
      If !Empty(cVend) .and. Substr(cVend,1,2) <> 'RT'
         MsgStop('De: Televen ...nao eh Televendas...'+cVend) 
         lRetMod2 := .f.
	      Return
      Endif
      If !Empty(cVend2) .and. Substr(cVend2,1,2) <> 'RL'
         MsgStop('De: Lubrifi ...nao eh Lubrificantes...'+cVend2) 
         lRetMod2 := .f.
	      Return
      Endif
      If !Empty(cVendN) .and. Substr(cVendN,1,2) <> 'RT'
         MsgStop('Para: Televen ...nao eh Televendas...'+cVendN) 
         lRetMod2 := .f.
	      Return
      Endif
      If !Empty(cVendN2) .and. Substr(cVendN2,1,2) <> 'RL'
         MsgStop('Para: Lubrifi ....nao eh Lubrificantes...'+cVendN2) 
         lRetMod2 := .f.
	      Return
      Endif  
      *
      * Conta qtde de clientes associados a um Televendas(RT) ou Lubrificantes(RL) ou ambos (RL+RT)
      *
      If Empty(cVendN) .and. Empty(cVendN2) // Campos Para: devem estar brancos para acontecer contagem!!!

	      For nIt := 1 To Len(aCols)
	
	       	cMun    := aCols[nIt,_nPosMun]
	
	         If !aCols[nIt,_nPosDel] .And. !Empty(cMun)
	         	
	         	nTotMun := nTotMun + 1
	         	cMun    := aCols[nIt,_nPosMun]
	
		         If !Empty(cVend) .and. Empty(cVend2) // Conta Somente Televendas(Atual) informada.
						cQuery := "SELECT COUNT(*) AS T_CLIENTE "
						cQuery += "FROM "+RetSqlName("SA1")+" "
						cQuery += "WHERE D_E_L_E_T_ = '' "
						cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
						cQuery += "AND A1_MUN  = '"+cMun+"' "
						cQuery += "AND A1_VEND = '"+cVend+"' "
						cQuery := ChangeQuery(cQuery)
						If (Select("MSA1") <> 0)
							dbSelectArea("MSA1")
							dbCloseArea()
						Endif
						TCQuery cQuery NEW ALIAS "MSA1"
	   				TCSetField("MSA1","T_CLIENTE" ,"N",08,0)
					   If !Eof()
						   nTotCli := nTotCli + MSA1->T_CLIENTE
					   Endif
		         Endif
		         If Empty(cVend) .and. !Empty(cVend2) // Conta Somente Lufrificante(Atual) informada.
						cQuery := "SELECT COUNT(*) AS T_CLIENTE "
						cQuery += "FROM "+RetSqlName("SA1")+" "
						cQuery += "WHERE D_E_L_E_T_ = '' "
						cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
						cQuery += "AND A1_MUN  = '"+cMun+"' "
						cQuery += "AND A1_VEND2 = '"+cVend2+"' "
						cQuery := ChangeQuery(cQuery)
						If (Select("MSA1") <> 0)
							dbSelectArea("MSA1")
							dbCloseArea()
						Endif
						TCQuery cQuery NEW ALIAS "MSA1"
	   				TCSetField("MSA1","T_CLIENTE" ,"N",08,0)
					   If !Eof()
						   nTotCli := nTotCli + MSA1->T_CLIENTE
					   Endif
		         Endif
		         If !Empty(cVend) .and. !Empty(cVend2) // Conta para Televendas(Atual) e Lubrificante(Atual) informada.
						cQuery := "SELECT COUNT(*) AS T_CLIENTE "
						cQuery += "FROM "+RetSqlName("SA1")+" "
						cQuery += "WHERE D_E_L_E_T_ = '' "
						cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
						cQuery += "AND A1_MUN  = '"+cMun+"' "
						cQuery += "AND A1_VEND = '"+cVend+"' "
		                cQuery += "AND A1_VEND2 = '"+cVend2+"' "
						cQuery := ChangeQuery(cQuery)
						If (Select("MSA1") <> 0)
							dbSelectArea("MSA1")
							dbCloseArea()
						Endif
						TCQuery cQuery NEW ALIAS "MSA1"
	   				TCSetField("MSA1","T_CLIENTE" ,"N",08,0)
					   If !Eof()
						   nTotCli := nTotCli + MSA1->T_CLIENTE
					   Endif
		         Endif
		      EndIf
	      Next nIt  
	      If nTotMun > 0
	         MsgStop(' Total de clientes associados...'+str(nTotCli)+" Para "+str(nTotMun)+" Cidades!") 
	         lRetMod2   := .t.
	         loop
	      Endif
	   EndIf
      If Empty(cVendN) .and. Empty(cVendN2) // Campos Para: devem estar brancos para acontecer contagem!!!
         If !Empty(cVend) .and. Empty(cVend2) // Conta somente caso Televendas soh tenha sido informada.
				cQuery := "SELECT COUNT(*) AS T_CLIENTE "
				cQuery += "FROM "+RetSqlName("SA1")+" "
				cQuery += "WHERE D_E_L_E_T_ = '' "
				cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
				cQuery += "AND A1_VEND = '"+cVend+"' "
				cQuery := ChangeQuery(cQuery)
				If (Select("MSA1") <> 0)
					dbSelectArea("MSA1")
					dbCloseArea()
				Endif
				TCQuery cQuery NEW ALIAS "MSA1"
				TCSetField("MSA1","T_CLIENTE" ,"N",08,0)
				If !Eof()
					nTotCli := MSA1->T_CLIENTE
				Endif
            MsgStop('De: Televen ....'+cVend+' Total de clientes associados...'+str(nTotCli)) 
            lRetMod2   := .t.
            loop
   		EndIf
         If Empty(cVend) .and. !Empty(cVend2) // Conta somente caso Lubrificante soh tenha sido informada.
				cQuery := "SELECT COUNT(*) AS T_CLIENTE "
				cQuery += "FROM "+RetSqlName("SA1")+" "
				cQuery += "WHERE D_E_L_E_T_ = '' "
				cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
				cQuery += "AND A1_VEND2 = '"+cVend2+"' "
				cQuery := ChangeQuery(cQuery)
				If (Select("MSA1") <> 0)
					dbSelectArea("MSA1")
					dbCloseArea()
				Endif
				TCQuery cQuery NEW ALIAS "MSA1"
				TCSetField("MSA1","T_CLIENTE" ,"N",08,0)
				If !Eof()
					nTotCli := MSA1->T_CLIENTE
				Endif
            MsgStop('De: Lufrifi ....'+cVend2+' Total de clientes associados...'+str(nTotCli)) 
            lRetMod2   := .t.
            loop
    		EndIf
         If !Empty(cVend) .and. !Empty(cVend2) // Conta caso ambos Televendas e Lubrificantes tenham sido informados
				cQuery := "SELECT COUNT(*) AS T_CLIENTE "
				cQuery += "FROM "+RetSqlName("SA1")+" "
				cQuery += "WHERE D_E_L_E_T_ = '' "
				cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
				cQuery += "AND A1_VEND  = '"+cVend+"' "
				cQuery += "AND A1_VEND2 = '"+cVend2+"' "
				cQuery := ChangeQuery(cQuery)
				If (Select("MSA1") <> 0)
					dbSelectArea("MSA1")
					dbCloseArea()
				Endif
				TCQuery cQuery NEW ALIAS "MSA1"
				TCSetField("MSA1","T_CLIENTE" ,"N",08,0)
				If !Eof()
					nTotCli := MSA1->T_CLIENTE
				Endif
            MsgStop('De: Televen e Lufrifi....'+cVend+' / '+cVend2+' Total de clientes associados...'+str(nTotCli)) 
            lRetMod2   := .t.
            loop
    		EndIf
      Endif  

      IF !MsgYesNo("Confirma Atualizacao para esta nova carteira ? "+cVendN+" / "+cVendN2)
         lRetMod2   := .t.
         loop
      Endif

      *
      * Fase de associaçao de vendedor (Televendas ou Lubrificantes ou ambos)
      *
      SA1->(DbSetOrder(1))               // filial+cod+loja
      
      nTotCli := 0  
      nTotMun := 0
      *
      * Efetua associaçao por cidade informadas.
      *
      For nIt := 1 To Len(aCols)

       	cMun    := aCols[nIt,_nPosMun]

         If !aCols[nIt,_nPosDel] .And. !Empty(cMun)
         	
         	nTotMun := nTotMun + 1
         	cMun    := aCols[nIt,_nPosMun]

	         If !Empty(cVend) .and. Empty(cVend2) // Associa com base em Televendas(Atual) informada.
					cQuery := "SELECT A1_COD, A1_LOJA "
					cQuery += "FROM "+RetSqlName("SA1")+" "
					cQuery += "WHERE D_E_L_E_T_ = '' "
					cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
					cQuery += "AND A1_VEND = '"+cVend+"' "
					cQuery += "AND A1_MUN  = '"+cMun+"' "
					cQuery := ChangeQuery(cQuery)
					If (Select("MSA1") <> 0)
						dbSelectArea("MSA1")
						dbCloseArea()
					Endif
					TCQuery cQuery NEW ALIAS "MSA1"
					DbSelectArea("MSA1")
					DbGoTop()
					While !Eof()  
						dbSelectArea("SA1")
						dbSetOrder(1)
						If dbSeek(xFilial("SA1")+MSA1->A1_COD+MSA1->A1_LOJA)
						   SELE AGR262
						   If !DbSeek(SA1->A1_COD+SA1->A1_LOJA)
						      AGR262->(dbappend())
						      AGR262->COD     := SA1->A1_COD   
						      AGR262->LOJA    := SA1->A1_LOJA
						      AGR262->VEND    := SA1->A1_VEND
						      AGR262->VEND2   := SA1->A1_VEND2
						      AGR262->VENDN   := cVendN       
						      AGR262->VENDN2  := cVendN2        
						      MSUNLOCK('AGR262')
						   EndIf
							RecLock("SA1",.F.)
							If !Empty(cVendN)
							   SA1->A1_VEND := cVendN  // Nova Televendas
							Endif
							If !Empty(cVendN2)
							   SA1->A1_VEND2 := cVendN2 // Novo Lubrificante
							Endif
							MsUnlock('SA1')
						endif
						nTotCli := nTotCli + 1
						DbSelectArea("MSA1")
						DbSkip()
					EndDo
	         Endif
	         If Empty(cVend) .and. !Empty(cVend2) // Associa Com base em Lubrificante(Atual) informada.
					cQuery := "SELECT A1_COD, A1_LOJA "
					cQuery += "FROM "+RetSqlName("SA1")+" "
					cQuery += "WHERE D_E_L_E_T_ = '' "
					cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
					cQuery += "AND A1_VEND2 = '"+cVend2+"' "
					cQuery += "AND A1_MUN  = '"+cMun+"' "
					cQuery := ChangeQuery(cQuery)
					If (Select("MSA1") <> 0)
						dbSelectArea("MSA1")
						dbCloseArea()
					Endif
					TCQuery cQuery NEW ALIAS "MSA1"
					DbSelectArea("MSA1")
					DbGoTop()
					While !Eof()  
						dbSelectArea("SA1")
						dbSetOrder(1)
						If dbSeek(xFilial("SA1")+MSA1->A1_COD+MSA1->A1_LOJA)
						   SELE AGR262
						   If !DbSeek(SA1->A1_COD+SA1->A1_LOJA)
						      AGR262->(dbappend())
						      AGR262->COD     := SA1->A1_COD   
						      AGR262->LOJA    := SA1->A1_LOJA
						      AGR262->VEND    := SA1->A1_VEND
						      AGR262->VEND2   := SA1->A1_VEND2
						      AGR262->VENDN   := cVendN       
						      AGR262->VENDN2  := cVendN2        
						      MSUNLOCK('AGR262')
						   EndIf
							RecLock("SA1",.F.)
							If !Empty(cVendN)
							   SA1->A1_VEND := cVendN // Nova Televendas
							Endif
							If !Empty(cVendN2)
							   SA1->A1_VEND2 := cVendN2 // Novo Lubrificante
							Endif
							MsUnlock('SA1')
						endif
						nTotCli := nTotCli + 1
   					DbSelectArea("MSA1")
						DbSkip()
					EndDo
	         Endif
	         If !Empty(cVend) .and. !Empty(cVend2) // Associa Com base em Televendas(Atual) e Lubrificante(Atual) informada.
					cQuery := "SELECT A1_COD, A1_LOJA "
					cQuery += "FROM "+RetSqlName("SA1")+" "
					cQuery += "WHERE D_E_L_E_T_ = '' "
					cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
					cQuery += "AND A1_VEND  = '"+cVend+"' "
					cQuery += "AND A1_VEND2 = '"+cVend2+"' "
					cQuery += "AND A1_MUN  = '"+cMun+"' "
					cQuery := ChangeQuery(cQuery)
					If (Select("MSA1") <> 0)
						dbSelectArea("MSA1")
						dbCloseArea()
					Endif
					TCQuery cQuery NEW ALIAS "MSA1"
					DbSelectArea("MSA1")
					DbGoTop()
					While !Eof()  
						dbSelectArea("SA1")
						dbSetOrder(1)
						If dbSeek(xFilial("SA1")+MSA1->A1_COD+MSA1->A1_LOJA)
						   SELE AGR262
						   If !DbSeek(SA1->A1_COD+SA1->A1_LOJA)
						      AGR262->(dbappend())
						      AGR262->COD     := SA1->A1_COD   
						      AGR262->LOJA    := SA1->A1_LOJA
						      AGR262->VEND    := SA1->A1_VEND
						      AGR262->VEND2   := SA1->A1_VEND2
						      AGR262->VENDN   := cVendN       
						      AGR262->VENDN2  := cVendN2        
						      MSUNLOCK('AGR262')
						   EndIf
							RecLock("SA1",.F.)
							If !Empty(cVendN)
							   SA1->A1_VEND := cVendN // Nova Televendas
							Endif
							If !Empty(cVendN2)
							   SA1->A1_VEND2 := cVendN2 // Novo Lubrificante
							Endif
							MsUnlock('SA1')
						endif
						nTotCli := nTotCli + 1
						DbSelectArea("MSA1")
						DbSkip()
					EndDo
	         Endif
	         
         Endif

      Next nIt  

      *
      * Efetua associaçao direto sem considerar cidades.
      *
      If nTotMun = 0
      
         If !Empty(cVend) .and. Empty(cVend2) // Associa com base em Televendas(Atual) informada.
				cQuery := "SELECT A1_COD, A1_LOJA "
				cQuery += "FROM "+RetSqlName("SA1")+" "
				cQuery += "WHERE D_E_L_E_T_ = '' "
				cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
				cQuery += "AND A1_VEND = '"+cVend+"' "
				cQuery := ChangeQuery(cQuery)
				If (Select("MSA1") <> 0)
					dbSelectArea("MSA1")
					dbCloseArea()
				Endif
				TCQuery cQuery NEW ALIAS "MSA1"
				DbSelectArea("MSA1")
				DbGoTop()
				While !Eof()  
					dbSelectArea("SA1")
					dbSetOrder(1)
					If dbSeek(xFilial("SA1")+MSA1->A1_COD+MSA1->A1_LOJA)
					   SELE AGR262
					   If !DbSeek(SA1->A1_COD+SA1->A1_LOJA)
					      AGR262->(dbappend())
					      AGR262->COD     := SA1->A1_COD   
					      AGR262->LOJA    := SA1->A1_LOJA
					      AGR262->VEND    := SA1->A1_VEND
					      AGR262->VEND2   := SA1->A1_VEND2
					      AGR262->VENDN   := cVendN       
					      AGR262->VENDN2  := cVendN2        
					      MSUNLOCK('AGR262')
					   EndIf
						RecLock("SA1",.F.)
						If !Empty(cVendN)
						   SA1->A1_VEND := cVendN  // Nova Televendas
						Endif
						If !Empty(cVendN2)
						   SA1->A1_VEND2 := cVendN2 // Novo Lubrificante
						Endif
						MsUnlock('SA1')
					endif
					nTotCli := nTotCli + 1
					DbSelectArea("MSA1")
					DbSkip()
				EndDo
         Endif
         If Empty(cVend) .and. !Empty(cVend2) // Associa com base em Lubrificante(Atual) informada.
				cQuery := "SELECT A1_COD, A1_LOJA "
				cQuery += "FROM "+RetSqlName("SA1")+" "
				cQuery += "WHERE D_E_L_E_T_ = '' "
				cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
				cQuery += "AND A1_VEND2 = '"+cVend2+"' "
				cQuery := ChangeQuery(cQuery)
				If (Select("MSA1") <> 0)
					dbSelectArea("MSA1")
					dbCloseArea()
				Endif
				TCQuery cQuery NEW ALIAS "MSA1"
				DbSelectArea("MSA1")
				DbGoTop()
				While !Eof()  
					dbSelectArea("SA1")
					dbSetOrder(1)
					If dbSeek(xFilial("SA1")+MSA1->A1_COD+MSA1->A1_LOJA)
					   SELE AGR262
					   If !DbSeek(SA1->A1_COD+SA1->A1_LOJA)
					      AGR262->(dbappend())
					      AGR262->COD     := SA1->A1_COD   
					      AGR262->LOJA    := SA1->A1_LOJA
					      AGR262->VEND    := SA1->A1_VEND
					      AGR262->VEND2   := SA1->A1_VEND2
					      AGR262->VENDN   := cVendN       
					      AGR262->VENDN2  := cVendN2        
					      MSUNLOCK('AGR262')
					   EndIf
						RecLock("SA1",.F.)
						If !Empty(cVendN)
						   SA1->A1_VEND := cVendN  // Nova Televendas
						Endif
						If !Empty(cVendN2)
						   SA1->A1_VEND2 := cVendN2 // Novo Lubrificante
						Endif
						MsUnlock('SA1')
					endif
					nTotCli := nTotCli + 1
					DbSelectArea("MSA1")
					DbSkip()
				EndDo
         Endif
         If !Empty(cVend) .and. !Empty(cVend2) // Associa com base em Televendas(Atual) e Lubrificante(Atual) informada.
				cQuery := "SELECT A1_COD, A1_LOJA "
				cQuery += "FROM "+RetSqlName("SA1")+" "
				cQuery += "WHERE D_E_L_E_T_ = '' "
				cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
				cQuery += "AND A1_VEND  = '"+cVend+"' "
				cQuery += "AND A1_VEND2 = '"+cVend2+"' "
				cQuery := ChangeQuery(cQuery)
				If (Select("MSA1") <> 0)
					dbSelectArea("MSA1")
					dbCloseArea()
				Endif
				TCQuery cQuery NEW ALIAS "MSA1"
				DbSelectArea("MSA1")
				DbGoTop()
				While !Eof()  
					dbSelectArea("SA1")
					dbSetOrder(1)
					If dbSeek(xFilial("SA1")+MSA1->A1_COD+MSA1->A1_LOJA)
					   SELE AGR262
					   If !DbSeek(SA1->A1_COD+SA1->A1_LOJA)
					      AGR262->(dbappend())
					      AGR262->COD     := SA1->A1_COD   
					      AGR262->LOJA    := SA1->A1_LOJA
					      AGR262->VEND    := SA1->A1_VEND
					      AGR262->VEND2   := SA1->A1_VEND2
					      AGR262->VENDN   := cVendN       
					      AGR262->VENDN2  := cVendN2        
					      MSUNLOCK('AGR262')
					   EndIf
						RecLock("SA1",.F.)
						If !Empty(cVendN)
						   SA1->A1_VEND := cVendN  // Nova Televendas
						Endif
						If !Empty(cVendN2)
						   SA1->A1_VEND2 := cVendN2 // Novo Lubrificante
						Endif
						MsUnlock('SA1')
					endif
					nTotCli := nTotCli + 1
					DbSelectArea("MSA1")
					DbSkip()
				EndDo
         Endif
         
      Endif

      If nTotMun > 0
		   MsgStop("Para a carteira "+cVendN+" / "+cVendN2 + " Totalizado: "+str(nTotCli)+" Clientes Atualizados!!! em "+str(nTotMun)+" Cidades ! ")
      Else
		   MsgStop("Para a carteira "+cVendN+" / "+cVendN2 + " Totalizado: "+str(nTotCli)+" Clientes Atualizados!!!")
      EndIf
      
      S262IMP() // Impressao clientes alterados para nova carteira com posicao anterior e atual para controle
      
	   Return

   Endif
   
   If !lRetMod2
	
	   #IFDEF WINDOWS
		   MsgStop("Voce abortou a operacao!")
	   #ELSE
	      Alert("Voce abortou a operacao!")
	   #ENDIF
	
	   Return
	
   Endif

End   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ S262IMP ºAutor  ³ DECO                º Data ³  20/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprimir Cateira da Alteraçao                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function S262IMP(cAlias,nReg,nOpc)
************************************ 
cPerg     := ""
Limite   := 132
cString  :="SA1"
cDesc1   := OemToAnsi("Este programa tem como objetivo, imprimir o relatorio")
cDesc2   := OemToAnsi("da carteira de cliente que sofreu alteraçao dos vendedores")
cDesc3   := ""
nChar    := 18
Tamanho  := "M"
cProduto := ""

aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
NomeProg := "AGR262"
aLinha   := {}
nLastKey := 0

Titulo   := "CARTEIRA DE CLIENTE X VENDEDOR ATUALIZADA"
Cabec1  := "Cliente                                                                                 Carteira Anterior     Carteira Atual"
Cabec2  := ""
Cancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 1        //Variavel que acumula numero da pagina
wnrel    := "AGR262" //Nome Default do relatorio em Disco

If FunName() == "AGR262"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas .³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPerg := "AGR262"
	pergunte(cPerg,.F.)
	
	SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho)
Else
	SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho)
Endif

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape  .³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

SetPrc(0,0)
@ 000,000 PSAY CHR(18)

If li > 55    
	Roda(0,"","M")     			
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
	Li := 8			
End

lFirst:=.T.

SELE AGR262
DbGotop()
While !Eof()
	
	nPagA := 1
	    
	Li++
	If li > 55    
		Roda(0,"","M")     			
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
		Li := 8			
	End

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+AGR262->COD+AGR262->LOJA)
	
	@ Li,002		PSAY AGR262->COD
	@ Li,010		PSAY AGR262->LOJA
	@ Li,015		PSAY SA1->A1_NOME
	@ Li,060		PSAY SA1->A1_MUN
	@ Li,085		PSAY SA1->A1_EST
	@ Li,090		PSAY AGR262->VEND
	@ Li,100		PSAY AGR262->VEND2
	@ Li,110		PSAY AGR262->VENDN
	@ Li,120		PSAY AGR262->VENDN2
	
	Sele AGR262
	DbSkip()
	Loop
	       
End

//Fecho arquivos utilizados
///////////////////////////
If (Select("MSA1") <> 0)
	dbSelectArea("MSA1")
	dbCloseArea()
Endif
If (Select("AGR262") <> 0)
	dbSelectArea("AGR262")
	dbCloseArea()
	If File(cArq+OrdBagExt())
		FErase(cArq+OrdBagExt())
	Endif
Endif

Set Device To Screen

SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
EndIf

MS_FLUSH()   

Return


Return
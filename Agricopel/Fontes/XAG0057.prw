#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

User Function XAG0057(aParam)

Local lCPParte := .F. //-- Define que não será processado o custo em partes
Local lBat := .T. //-- Define que a rotina será executada em Batch
Local aListaFil := {} //-- Carrega Lista com as Filiais a serem processadas
Local cCodFil := '' //-- Código da Filial a ser processada 
Local cNomFil := '' //-- Nome da Filial a ser processada
Local cCGC := '' //-- CGC da filial a ser processada                                     
Local aParAuto:= {} //Carrega a lista com os 21 parâmetros
/*/
MV_PAR01 = "31/12/2019",
MV_PAR02 = Mostra lanctos. Contábeis
MV_PAR03 = Aglutina Lanctos Contábeis
MV_PAR04 = Atualizar Arq. de Movimentos
MV_PAR05 = % de aumento da MOD
MV_PAR06 = Centro de Custo
MV_PAR07 = Conta Contábil a inibir de
MV_PAR08 = Conta Contábil a inibir até
MV_PAR09 = Apagar estornos
MV_PAR010 = Gerar Lancto. Contábil
MV_PAR011 = Gerar estrutura pela Moviment
MV_PAR012 = Contabilização On-Line Por 0
MV_PAR013 = Calcula mão-de-Obra
MV_PAR014 = Método de apropriação
MV_PAR015 = Recalcula Nível de Estrut
MV_PAR016 = Mostra sequência de Cálculo
MV_PAR017 = Seq Processamento FIFO
MV_PAR018 = Mov Internos Valorizados
MV_PAR019 = Recálculo Custo transportes
MV_PAR020 = Cálculo de custos por
MV_PAR021 = Calcular Custo em Partes} //-- Carrega a lista com os 21 parâmetros
/*/                                                                                                   


PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO "EST" TABLES "AF9","SB1","SB2","SB3","SB8","SB9","SBD","SBF","SBJ","SBK","SC2","SC5","SC6","SD1","SD2","SD3","SD4","SD5","SD8","SDB","SDC","SF1","SF2","SF4","SF5","SG1","SI1","SI2","SI3","SI5","SI6","SI7","SM2","ZAX","SAH","SM0","STL"
      
aParAuto:= {dDataBase ,;
    2,;
    2,;
    1,;
    0,;
    1,;
    "               " ,;
    "ZZZZZZZZZZZZZZZ" ,;
    1,;
    2,;
    2,;
    3,;
    2,;
    2,;
    1,;
    1,;
    1,;
    1,;
    2,;
    2,;
    2}
Conout("Início da execução do XAG0057")

//-- Adiciona filial a ser processada
ConOut(aParam[1])
ConOut(aParam[2])

dbSelectArea("SM0")
dbSeek(aParam[1])
Do While ! Eof() .And. SM0->M0_CODIGO == aParam[1] 
   cCodFil := Alltrim(SM0->M0_CODFIL)
   cNomFil := SM0->M0_FILIAL
   cCGC := SM0->M0_CGC
   //-- Somente adiciona a Filial do parametro aParam[2]
   //ConOut(SM0->M0_CODIGO)
   //ConOut(Alltrim(SM0->M0_CODFIL))

   If cCodFil == aParam[2]
      //-- Adiciona a filial na lista de filiais a serem processadas
      Aadd(aListaFil,{.T.,cCodFil,cNomFil,cCGC,.F.,})
   EndIf 
   dbSkip()
EndDo

//-- Executa a rotina de recálculo do custo médio
MATA330(lBat,aListaFil,lCPParte, aParAuto)

ConOut("Término da execução do XAG0057")

Return
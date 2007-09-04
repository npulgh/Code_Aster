      SUBROUTINE NMMESS (CODE,DP0,DP1,DP,FONC,NIT,NITMAX,IRET)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 04/09/2007   AUTEUR DURAND C.DURAND 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR   
C (AT YOUR OPTION) ANY LATER VERSION.                                 
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT 
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF          
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU    
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                            
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE   
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,       
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
C TOLE CRP_7

      IMPLICIT NONE
      INTEGER NIT,NITMAX,IRET
      REAL*8 DP0,DP1,DP
      CHARACTER*1 CODE

C ......................................................................
C    - FONCTION REALISEE: MESSAGE D'ERREUR DETAILLE EN CAS DE NON
C                         CONVERGENCE DANS LES ROUTINES DE RECHERCHE
C                         DE ZERO DE F(DP)
C
C    - ARGUMENTS:
C        DONNEES:     CODE    : 'A', 'E' OU 'F' PASSE A U2MESG
C                     DP0     : DP INITIAL (0 EN GENERAL)
C                     DP1     : DP MAXI ESTIME
C                     DP      : DERNIER DP CALCULE
C                     FONC    : NOM DE LA FONCTION
C                     NIT     : NOMBRE D'ITERATIONS ATTEINT
C                     NITMAX  : NOMBRE D'ITERATIONS MAXIMUM
C                     IRET    : CODE RETOUR DE L'ALGO DE RECHERCHE
C                               IRET = 0 : OK
C                               IRET = 1 : ON NE TROUVE PAS DPMAX
C                               IRET = 2 : NITER INSUFFISANT
C                               IRET = 3 : F(XMIN) > 0
C ......................................................................

C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*8 ZK8,NOMAIL
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*24 VALK
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C ---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------

      INTEGER IADZI,IAZK24,NBP,I
      INTEGER VALI(2)
      EXTERNAL FONC
      REAL*8 FONC,DPI,F0,F1,FP,FI
      REAL*8 VALR(2)

      IF (IRET.EQ.0) GOTO 9999

      CALL TECAEL(IADZI,IAZK24)
      NOMAIL= ZK24(IAZK24-1+3)(1:8)


      IF (IRET.EQ.1) THEN
         CALL U2MESG(CODE//'+','ALGORITH15_45',0,' ',0,0,0,0.D0)
      ELSEIF (IRET.EQ.2) THEN
         CALL U2MESG(CODE//'+','ALGORITH15_46',0,' ',0,0,0,0.D0)
      ELSEIF (IRET.EQ.3) THEN
         CALL U2MESG(CODE//'+','ALGORITH15_47',0,' ',0,0,0,0.D0)
      ENDIF

      VALK = NOMAIL
      VALI (1) = NIT
      VALI (2) = NITMAX
      CALL U2MESG(CODE//'+','ALGORITH15_48',1,VALK,2,VALI,0,0.D0)
      FP = FONC(DP)
      VALR (1) = DP
      VALR (2) = FP
      CALL U2MESG(CODE//'+','ALGORITH15_49',0,' ',0,0,2,VALR)
      F0 = FONC(DP0)
      VALR (1) = DP0
      VALR (2) = F0
      CALL U2MESG(CODE//'+','ALGORITH15_50',0,' ',0,0,2,VALR)
      F1 = FONC(DP1)
      VALR (1) = DP1
      VALR (2) = F1
      CALL U2MESG(CODE//'+','ALGORITH15_51',0,' ',0,0,2,VALR)
      NBP=100

      VALI (1) = NBP
      CALL U2MESG(CODE//'+','ALGORITH15_52',0,' ',1,VALI,0,0.D0)
      DO 10 I=1,NBP
         DPI=DP0+I*(DP1-DP0)/NBP
         FI = FONC(DPI)
         VALR (1) = DPI
         VALR (2) = FI
         CALL U2MESG(CODE//'+','ALGORITH15_53',0,' ',0,0,2,VALR)
10    CONTINUE

      CALL U2MESG(CODE,'ALGORITH15_54',0,' ',0,0,0,0.D0)
9999  CONTINUE
      END

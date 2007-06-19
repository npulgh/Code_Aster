      SUBROUTINE RECPAR(NEQ,VMIN,VVAR,CMP,CDP,CPMIN,NPER,NRMAX)
C
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8      VMIN(*),CMP,CPMIN
      REAL*8 VALR(3)
      CHARACTER*8 VVAR
      CHARACTER*24 VALK
      INTEGER     NEQ,NPER,NRMAX,METH
      INTEGER VALI(2)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/06/2007   AUTEUR LEBOUVIER F.LEBOUVIER 
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
C     RECUPERATION DES PARAMETRES D'ADAPTATION DU PAS
C-----------------------------------------------------------------------
C IN  : NEQ    : NOMBRE D'EQUATION
C OUT : VMIN   : TABLEAU DES VITESSES MINIMALES (PAR DDL)
C OUT : VVAR   : METHODE POUR CALCUL DE LA VITESSE MINIMALE 
C                ('NORM' OU 'MAXI')
C OUT : CMP    : COEFFICIENT DE REMONTEE DU PAS DE TEMPS
C OUT : CDP    : COEFFICIENT DE DIVISION DU PAS DE TEMPS
C OUT : CPMIN  : COEFFICIENT APPLIQUE A DT INITIAL POUR OBTENIR
C                DT MIN
C OUT : NPER   : NOMBRE DE POINTS PAR PERIODE
C OUT : NRMAX  : NOMBRE MAXIMAL DE REDUCTION DU PAS DE TEMPS
C                PAR PAS DE CALCUL
C
C
C     --- VITESSE DE REFERENCE ---
C
        CALL GETVTX('INCREMENT','VITE_MIN',1,1,1,VVAR,NV)
        DO 10 I=1,NEQ
         VMIN(I) = 1.D-15
 10     CONTINUE  
C
C     --- COEFFICIENT DE REMONTEE DU PAS DE TEMPS ---
C
      CALL GETVR8('INCREMENT','COEF_MULT_PAS'   ,1,1,1,CMP,N1)
C
C     --- COEFFICIENT DE DIVISION DU PAS DE TEMPS ---
C
      CALL GETVR8('INCREMENT','COEF_DIVI_PAS'   ,1,1,1,CDP,N1)
C
C     --- COEFFICIENT DETERMINANT DT MIN (=DT INIT * CPMIN) --
C
      CALL GETVR8('INCREMENT','PAS_LIMI_RELA'   ,1,1,1,CPMIN,N1)
C
C     --- NOMBRE DE POINTS PAR PERIODE
C
      CALL GETVIS('INCREMENT','NB_POIN_PERIODE',1,1,1,NPER,N1)
C
C     --- NMAX_REDUC_PAS
C
      CALL GETVIS('INCREMENT','NMAX_ITER_PAS',1,1,1,NRMAX,N1)
C
C
      VALI (1) = NPER
      VALI (2) = NRMAX
      VALR (1) = CMP
      VALR (2) = CDP
      VALR (3) = CPMIN
      VALK = VVAR
      CALL U2MESG('I','ALGORITH15_68',1,VALK,2,VALI,3,VALR)
      END

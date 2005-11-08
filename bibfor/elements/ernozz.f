      SUBROUTINE ERNOZZ (MODELE,SIGMA,CHMAT,SIGNO,OPTION,RESU,LIGREL,
     &                   IORDR, TIME, RESUCO )
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*)      MODELE,SIGMA,CHMAT,SIGNO,OPTION,RESU,
     &                   LIGREL,RESUCO
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 08/11/2005   AUTEUR CIBHHLV L.VIVAN 
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
C
C     BUT :  CALCULER LES ESTIMATEURS GLOBAUX DE LA METHODE ZZ
C            A PARTIR DES ESTIMATEURS LOCAUX CONTENUS DANS CHAMP
C
C IN  : MODELE :  NOM DU MODELE
C IN  : SIGMA  :  CONTRAINTES AUX POINTS DE GAUSS
C IN  : CHMAT  :  NOM DU CHAMP DE MATERIAU
C IN  : SIGNO  :  CONTRAINTES AUX NOEUDS
C IN  : OPTION :  'ERRE_ELEM_NOZ1' OU 'ERRE_ELEM_NOZ2'
C OUT : RESU   :  CONTRAINTES AUX NOEUDS
C IN  : LIGREL :  NOM D'UN LIGREL SUR LEQUEL ON FERA LE CALCUL
C ----------------------------------------------------------------------
C
      CHARACTER*8   K8B, CHTEMP
      COMPLEX*16    CBID
C
C    CALCUL DE L'ESTIMATEUR D'ERREUR
C
      CHTEMP = '&&TEMP'
      CALL MECACT('V',CHTEMP,'LIGREL',LIGREL,'TEMP_R',1,'TEMP',
     +                                        IBID,0.0D0,CBID,K8B)
      CALL ZZLOCA(MODELE,LIGREL,CHMAT,CHTEMP,SIGMA,SIGNO,RESU)
      CALL ZZGLOB ( RESU, OPTION, IORDR, TIME, RESUCO )
C
      END

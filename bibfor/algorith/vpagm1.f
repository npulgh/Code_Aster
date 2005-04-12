      FUNCTION VPAGM1(PORO)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 11/04/2005   AUTEUR F6BHHBO P.DEBONNIERES 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C TOLE CRP_7
      IMPLICIT NONE
      REAL*8   PORO
      REAL*8   VPAGM1     
C
CDEB
C---------------------------------------------------------------
C     FONCTION A(X)  :  CAS DE LA LOI GATT-MONERIE
C---------------------------------------------------------------
C IN  X     :R: ARGUMENT RECHERCHE LORS DE LA RESOLUTION SCALAIRE
C---------------------------------------------------------------
C     L'ETAPE LOCALE DU CALCUL VISCOPLASTIQUE (CALCUL DU TERME
C       ELEMENTAIRE DE LA MATRICE DE RIGIDITE TANGENTE) COMPORTE
C       LA RESOLUTION D'UNE EQUATION SCALAIRE NON LINEAIRE:
C
C           A(X) = 0
C
C       (DPC,SIELEQ,DEUXMU,DELTAT JOUENT LE ROLE DE PARAMETRES)
C---------------------------------------------------------------
CFIN
C     COMMON POUR LES PARAMETRES DES LOIS VISCOPLASTIQUES
      COMMON / NMPAVP /SIELEQ,DEUXMU,TROISK,DELTAT,TSCHEM,PREC,THETA,
     &                 NITER
      REAL*8           SIELEQ,DEUXMU,TROISK,DELTAT,TSCHEM,PREC,THETA,
     &                 NITER
     
C     COMMON POUR LES PARAMETRES DE LA LOI GATT-MONERIE
      COMMON / NMPAGM /AK1,AK2,XN1,XN2,EXPA1,EXPA2,EXPAB1,EXPAB2,A1,A2,
     &                 B1,B2,XW,XQ,XH,SIGE,SIGH,SIGH0,POROM,SGD
      REAL*8           AK1,AK2,XN1,XN2,EXPA1,EXPA2,EXPAB1,EXPAB2,A1,A2,
     &                 B1,B2,XW,XQ,XH,SIGE,SIGH,SIGH0,POROM,SGD

      REAL*8            VPAGM2
      EXTERNAL          VPAGM2      
      REAL*8   A0,XAP,X,G,DEVPKK,DGDST,DGDEV


      X = PORO - POROM
      SIGH = SIGH0 - (TROISK/3.D0)*(X/(1.D0-PORO))
C
C     PREMIER POTENTIEL
      A1    = (PORO**(2.D0/(XN1+1)))
     &           *(XN1*(1.D0 - PORO**EXPA1))**(-1.D0*EXPAB1)
      B1    = (1.D0+((2.D0/3.D0)*PORO))/((1.D0-PORO)**EXPAB1)  
C     SECOND POTENTIEL
      A2    = (PORO**(2.D0/(XN2+1)))
     &           *(XN2*(1.D0 - PORO**EXPA2))**(-1.D0*EXPAB2)
      B2    = (1.D0+((2.D0/3.D0)*PORO))/((1.D0-PORO)**EXPAB2)
C
      IF (PORO.LT.0.D0) WRITE(*,*) 'A2', A2, POROM, PORO
C
      A0 = - SIELEQ
      XAP = SIELEQ
      XAP = XAP - SIELEQ*1.D-12
      IF (ABS(A0).LE.PREC) THEN
        SIGE = 0.D0
      ELSE
        CALL ZEROF2(VPAGM2,A0,XAP,PREC*2,INT(NITER),SIGE)
      ENDIF
      CALL GGPGMO(SIGE,SIGH,
     *        THETA,DEUXMU,G,DEVPKK,DGDST,DGDEV,TSCHEM)
      VPAGM1 = X - (1.D0-POROM-X)*3.D0*DEVPKK*DELTAT
      VPAGM1 = VPAGM1*SGD
C      VPAGM1 = X
      END  

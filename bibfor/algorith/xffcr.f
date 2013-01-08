      SUBROUTINE XFFCR(NFON,JFONO,JBASO,JTAILO,JINDPT,TYPFON,JFON,JBAS,
     &                JTAIL)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 07/01/2013   AUTEUR LADIER A.LADIER 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER       NFON,JFONO,JBASO,JTAILO,JINDPT,JFON,JBAS,JTAIL
      CHARACTER*19  TYPFON
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM
C
C              ORDONNANCEMENT DES VECTEURS BASEFOND, FONDFISS ET
C              FOND.TAILLE_R
C
C ----------------------------------------------------------------------
C
C
C IN  NFON  :  NOMBRE DE POINTS AU FOND DE FISSURE
C     JFONO :  ADRESSE DES POINTS DU FOND DE FISSURE DÉSORDONNÉS
C     JBASO :  ADRESSE DES DIRECTIONS DE PROPAGATION DÉSORDONNÉES
C     JTAILO:  ADRESSE DES TAILLES MAXIMALES DE MAILLES DÉSORDONNÉES
C     JINDPT:  ADRESSE DES INDICES DES POINTS ORDONNES
C     TYPFON:  TYPE DU FOND DE FISSURE (OUVERT OU FERME)
C
C OUT JFON  :  ADRESSE DES POINTS DU FOND DE FISSURE ORDONNÉS
C     JBAS  :  ADRESSE DES DIRECTIONS DE PROPAGATION ORDONNÉES
C     JTAIL :  ADRESSE DES TAILLES MAXIMALES DE MAILLES ORDONNÉES

C
      INTEGER       INDIPT,IPT,K 
      REAL*8        M(3),P(3),PADIST
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()

      DO 10 IPT=1,NFON

        INDIPT = ZI(JINDPT-1+IPT)

        DO 11 K=1,3

          ZR(JFON-1+4*(IPT-1)+K)   = ZR(JFONO-1+4*(INDIPT-1)+K)
          ZR(JBAS-1+6*(IPT-1)+K)   = ZR(JBASO-1+6*(INDIPT-1)+K)
          ZR(JBAS-1+6*(IPT-1)+K+3) = ZR(JBASO-1+6*(INDIPT-1)+3+K)

 11     CONTINUE

        ZR(JFON-1+4*(IPT-1)+4)     = ZR(JFONO-1+4*(INDIPT-1)+4)
        ZR(JTAIL-1+IPT)            = ZR(JTAILO-1+INDIPT)

 10   CONTINUE

C     CAS D'UN FOND FERME: PREMIER POINT DU FOND = DERNIER POINT
      IF (TYPFON.EQ.'FERME')THEN

        NFON = NFON + 1

        DO 20 K=1,3

          ZR(JFON-1+4*(NFON-1)+K)   = ZR(JFON-1+4*(1-1)+K)
          ZR(JBAS-1+6*(NFON-1)+K)   = ZR(JBAS-1+6*(1-1)+K)
          ZR(JBAS-1+6*(NFON-1)+K+3) = ZR(JBAS-1+6*(1-1)+3+K)

          P(K) = ZR(JFON-1+4*(NFON-1)+K)
          M(K) = ZR(JFON-1+4*(NFON-2)+K)

 20     CONTINUE

        ZR(JFON-1+4*(NFON-1)+4)= ZR(JFON-1+4*(NFON-2)+4) + PADIST(3,M,P)
        ZR(JTAIL-1+NFON)       = ZR(JTAIL-1+1)

      ENDIF

      CALL JEDEMA()
      END

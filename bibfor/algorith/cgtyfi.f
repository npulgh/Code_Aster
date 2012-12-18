      SUBROUTINE CGTYFI(TYPFIS,NOMFIS)
      IMPLICIT NONE

      CHARACTER*8  TYPFIS,NOMFIS

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 17/12/2012   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GENIAUT S.GENIAUT
C
C     SOUS-ROUTINE DE L'OPERATEUR CALC_G
C
C     BUT : DETERMINATION DU TYPE ET DU NOM DE LA SD DECRIVANT LE
C           FOND DE FISSURE
C
C OUT :
C   TYPFIS : TYPE DE LA SD DECRIVANT LE FOND DE FISSURE
C            ('THETA' OU 'FONDIFSS' OU 'FISSURE')
C   NOMFIS : NOM DE LA SD DECRIVANT LE FOND DE FISSURE
C ======================================================================
C
      INTEGER      IARG,ITHET,IFOND,IFISS

      CALL JEMARQ()
C
      CALL GETVID('THETA','THETA'    ,1,IARG,1,NOMFIS,ITHET)
      CALL GETVID('THETA','FOND_FISS',1,IARG,1,NOMFIS,IFOND)
      CALL GETVID('THETA','FISSURE'  ,1,IARG,1,NOMFIS,IFISS)

      CALL ASSERT(ITHET.EQ.0.OR.ITHET.EQ.1)
      CALL ASSERT(IFOND.EQ.0.OR.IFOND.EQ.1)
      CALL ASSERT(IFISS.EQ.0.OR.IFISS.EQ.1)

C     NORMALEMENT, CETTE REGLE D'EXCLUSION EST VERIFIEE DANS LE CAPY
      CALL ASSERT(ITHET+IFOND+IFISS.EQ.1)

      IF (ITHET.EQ.1) THEN

        TYPFIS='THETA'

      ELSEIF (IFOND.EQ.1) THEN

        TYPFIS='FONDFISS'

      ELSEIF (IFISS.EQ.1) THEN

        TYPFIS='FISSURE'

      ENDIF

      CALL JEDEMA()

      END

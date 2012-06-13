      SUBROUTINE CFCORN(NEWGEO,NUMNO ,COORNO)
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      CHARACTER*19 NEWGEO
      INTEGER      NUMNO
      REAL*8       COORNO(3)
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - UTILITAIRE)
C
C COORDONNEES D'UN NOEUD
C
C ----------------------------------------------------------------------
C
C
C IN  NEWGEO : GEOMETRIE ACTUALISEE
C IN  NUMNO  : NUMERO ABSOLU DU NOEUD DANS LE MAILLAGE
C OUT COORNO : COORDONNEES DU NOEUD
C
C
C
C
      INTEGER      JCOOR
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      COORNO(1) = 0.D0
      COORNO(2) = 0.D0
      COORNO(3) = 0.D0
C
C --- COORDONNEES DU NOEUD 
C
      CALL JEVEUO(NEWGEO(1:19)//'.VALE','L',JCOOR)
      COORNO(1) = ZR(JCOOR+3*(NUMNO -1))
      COORNO(2) = ZR(JCOOR+3*(NUMNO -1)+1)
      COORNO(3) = ZR(JCOOR+3*(NUMNO -1)+2)
C
      CALL JEDEMA()
C 
      END

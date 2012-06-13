      SUBROUTINE ISCOQU(NOMO  ,NUMAIL,LCOQUE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8  NOMO
      INTEGER      NUMAIL 
      LOGICAL      LCOQUE
C     
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (TOUTES METHODES - LECTURE DONNEES)
C
C DETECTE SI UN ELEMENT EST DE TYPE COQUE_3D
C      
C ----------------------------------------------------------------------
C
C
C IN  NOMO   : NOM DU MODELE
C IN  NUMAIL : NUMERO ABSOLU DE LA MAILLE
C OUT LCOQUE : .TRUE. SI COQUE_3D
C
C
C
C
      INTEGER      IRET,IGREL,IEL
      INTEGER      IALIEL,ITYPEL
      INTEGER      NBGREL,NEL,NUMAI2
      CHARACTER*8  NOMTE,K8BID      
      CHARACTER*19 LIGRMO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      LCOQUE = .FALSE.      
C
C --- LIGREL DU MODELE
C 
      LIGRMO = NOMO(1:8)//'.MODELE'
      CALL JEEXIN(LIGRMO//'.LIEL',IRET)
      IF (IRET.EQ.0) THEN
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- NOMBRE DE GREL
C
      CALL JELIRA(LIGRMO(1:19)//'.LIEL','NUTIOC',NBGREL,K8BID) 
C
C --- BOUCLE SUR LES GREL
C
      DO 40 IGREL = 1,NBGREL
C
C --- TYPE DU GREL COURANT
C      
        CALL JEVEUO(JEXNUM(LIGRMO(1:19)//'.LIEL',IGREL),'L',IALIEL)
        CALL JELIRA(JEXNUM(LIGRMO(1:19)//'.LIEL',IGREL),'LONMAX',NEL,
     &                     K8BID)
        ITYPEL = ZI(IALIEL-1+NEL)
        CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',ITYPEL),NOMTE)
C
C --- CAS DES COQUES_3D
C
        IF ((NOMTE.EQ.'MEC3QU9H').OR.
     &      (NOMTE.EQ.'MEC3TR7H')) THEN   
C
C --- BOUCLE DANS LE GREL
C     
           DO 30 IEL = 1,NEL - 1
             NUMAI2 = ZI(IALIEL-1+IEL)
             IF (NUMAI2.EQ.NUMAIL) THEN
               LCOQUE = .TRUE.
               GOTO 40
             ENDIF     
  30       CONTINUE                  
        ENDIF      
  40  CONTINUE
C
      CALL JEDEMA()
      END

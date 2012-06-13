      SUBROUTINE CFNBEN(DEFICO,POSENT,TYPENT,NBENT ,JDECEN)
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
      CHARACTER*24 DEFICO
      CHARACTER*6  TYPENT
      INTEGER      POSENT
      INTEGER      NBENT
      INTEGER      JDECEN
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES MAILLEES - UTILITAIRE)
C
C ACCES AUX TABLEAUX DE CONNECTIVITES
C
C ----------------------------------------------------------------------
C
C
C IN  DEFICO : SD DE DEFINITION DU CONTACT 
C IN  POSENT : POSITION DE L'ENTITE DANS LES SD CONTACT
C IN  TYPENT : TYPE D'ENTITE
C               'CONINV' POSENT EST UN NOEUD   
C                  -> ON ACCEDE AUX MAILLES ATTACHEES A CE NOEUD
C                     (CONNECTIVITE INVERSE)
C               'CONNEX' POSENT EST UNE MAILLE
C                  -> ON ACCEDE AUX NOEUDS ATTACHES A CETTE MAILLE
C                     (CONENCTIVITE DIRECTE)
C OUT NBENT  : NOMBRE D'ENTITES ATTACHES
C OUT JDECEN : DECALAGE POUR TABLEAU 
C
C
C
C
      CHARACTER*24 PNOMA,PMANO
      INTEGER      JPONO,JPOMA
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C      
C --- RECUPERATION DE QUELQUES DONNEES      
C
      PNOMA  = DEFICO(1:16)//'.PNOMACO'
      PMANO  = DEFICO(1:16)//'.PMANOCO'     
      CALL JEVEUO(PNOMA, 'L',JPONO)
      CALL JEVEUO(PMANO ,'L',JPOMA) 
C
C --- INITIALISATIONS
C
      IF (TYPENT.EQ.'CONNEX') THEN
        NBENT  = ZI(JPONO+POSENT) - ZI(JPONO+POSENT-1)
        JDECEN = ZI(JPONO+POSENT-1)
      ELSEIF (TYPENT.EQ.'CONINV') THEN
        NBENT  = ZI(JPOMA+POSENT) - ZI(JPOMA+POSENT-1)   
        JDECEN = ZI(JPOMA+POSENT-1) 
      ELSE    
        CALL ASSERT(.FALSE.)
      ENDIF
C
      CALL JEDEMA()
C
      END

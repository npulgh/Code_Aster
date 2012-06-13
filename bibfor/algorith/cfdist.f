      SUBROUTINE CFDIST(DEFICO,METHOD,IZONE ,POSNOE,POSMAE,
     &                  COORD ,DIST  )
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
      CHARACTER*8  METHOD
      INTEGER      IZONE
      INTEGER      POSNOE,POSMAE
      REAL*8       DIST,COORD(3)
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES MAILLEES - APPARIEMENT)
C
C CALCUL DU JEU SUPPLEMENTAIRE
C
C ----------------------------------------------------------------------
C
C
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  METHOD : METHODE DE CONTACT
C               'CONTINUE'
C               'DISCRETE'
C IN  IZONE  : ZONE DE CONTACT
C IN  POSNOE : INDICE DU NOEUD ESCLAVE DANS CONTNO
C IN  POSMAE : INDICE DE LA MAILLE ESCLAVE DANS CONTMA
C IN  COORD  : VALEUR DES COORDONNEES DU NOEUD COURANT
C OUT DIST   : JEU SUPPLEMENTAIRE  
C
C
C
C
C
      INTEGER      IER
      CHARACTER*24 JEUPOU,JEUCOQ
      INTEGER      JJPOU,JJCOQ  
      CHARACTER*24 JEUFO1,JEUFO2
      INTEGER      JJFO1,JJFO2      
      CHARACTER*8  JEUF1,JEUF2
      CHARACTER*8  NOMPAR(3)
      REAL*8       VALPAR(3)
      REAL*8       DIST1,DIST2,DISTST
      LOGICAL      MMINFL,LDPOU,LDCOQ,LDESCL,LDMAIT
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- LECTURE DES SD POUR LE CONTACT POTENTIEL
C
      JEUCOQ = DEFICO(1:16)//'.JEUCOQ'
      JEUPOU = DEFICO(1:16)//'.JEUPOU' 
      JEUFO1 = DEFICO(1:16)//'.JFO1CO'
      JEUFO2 = DEFICO(1:16)//'.JFO2CO'     
C   
      CALL JEVEUO(JEUPOU,'L',JJPOU )
      CALL JEVEUO(JEUCOQ,'L',JJCOQ )      
      CALL JEVEUO(JEUFO1,'L',JJFO1 )
      CALL JEVEUO(JEUFO2,'L',JJFO2 )        
C
C --- INITIALISATIONS
C
      DIST1  = 0.D0
      DIST2  = 0.D0
      DISTST = 0.D0            
C
C --- EN VUE DE L'INTERPOLATION DU JEU PAR DES VARIABLES D'ESPACE
C
      NOMPAR(1) = 'X'
      NOMPAR(2) = 'Y'
      NOMPAR(3) = 'Z'
      VALPAR(1) = COORD(1)
      VALPAR(2) = COORD(2)
      VALPAR(3) = COORD(3)
C
C --- TYPES DE JEUX SUPS
C
      LDPOU  = MMINFL(DEFICO,'DIST_POUTRE',IZONE)
      LDCOQ  = MMINFL(DEFICO,'DIST_COQUE' ,IZONE)
      LDMAIT = MMINFL(DEFICO,'DIST_MAIT'  ,IZONE)
      LDESCL = MMINFL(DEFICO,'DIST_ESCL'  ,IZONE)       
C
C --- VALEUR DU JEU SUPPLEMENTAIRE SI C'EST UNE FONCTION DE L'ESPACE
C
      IF (LDMAIT) THEN
        JEUF1 = ZK8(JJFO1+IZONE-1)
        CALL FOINTE ('F',JEUF1,3,NOMPAR,VALPAR,DIST1,IER)
      ENDIF
C
C --- VALEUR DU JEU SUPPLEMENTAIRE SI C'EST UNE FONCTION DE L'ESPACE
C
      IF (LDESCL) THEN
        JEUF2 = ZK8(JJFO2+IZONE-1)
        CALL FOINTE ('F',JEUF2,3,NOMPAR,VALPAR,DIST2,IER)
      ENDIF      
C
C --- VALEUR DU JEU SUPPLEMENTAIRE SI DIST_POUTRE/DIST_COQUE
C
      IF (LDCOQ.OR.LDPOU) THEN
        IF (METHOD.EQ.'DISCRETE') THEN
          CALL CFDISM(DEFICO,LDPOU ,LDCOQ ,POSNOE,DISTST)
        ELSEIF (METHOD.EQ.'CONTINUE') THEN
          CALL ASSERT(POSNOE.EQ.0)        
          IF (LDPOU) THEN
            DISTST = DISTST+ZR(JJPOU-1+POSMAE)
          ENDIF        
          IF (LDCOQ) THEN
            DISTST = DISTST+ZR(JJCOQ-1+POSMAE)
          ENDIF          
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
      ENDIF
C
C --- TOTAL JEU SUPPLEMENTAIRE
C
      DIST   = DIST1 + DIST2 + DISTST 
C
      CALL JEDEMA ()
      END

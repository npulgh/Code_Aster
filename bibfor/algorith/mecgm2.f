      SUBROUTINE MECGM2(LISCHA,INSTAN,MESUIV)
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
      CHARACTER*19 MESUIV,LISCHA
      REAL*8       INSTAN
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL - UTILITAIRE)
C
C CALCUL DE LA LISTE DES COEFFICIENTS POUR MATR_ELEM CHARGEMENTS
C SUIVEURS
C      
C ----------------------------------------------------------------------
C
C
C IN  LISCHA : SD LISTE_CHARGES
C IN  INSTAN : INSTANT COURANT
C I/O MESUIV : MATR_ELEM SUIVEUR
C               OUT - MESUIV(1:15)//'.COEF'
C
C
C
C
      INTEGER      NBCHME,NCHAR
      INTEGER      IRET,ICHAR,ICHA,IER
      INTEGER      JMEC
      CHARACTER*8  K8BID   
      LOGICAL      FCT    
      CHARACTER*24 LICOEF,FOMULT 
      INTEGER      JLICOE,JFONCT
      REAL*8       VALRES  
      LOGICAL      BIDON          
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()     
C
C --- INITIALISATIONS
C      
      FOMULT = LISCHA(1:19)//'.FCHA'
      LICOEF = MESUIV(1:15)//'.COEF'
      BIDON  = .FALSE.
C
C --- NOMBRE DE CHARGEMENTS SUIVEURS
C
      CALL JEEXIN(MESUIV(1:19)//'.RELR',IRET)
      IF ( IRET .NE. 0 ) THEN
        CALL JELIRA(MESUIV(1:19)//'.RELR','LONUTI',NBCHME,K8BID)
        IF ( NBCHME .EQ. 0 ) THEN
          BIDON = .TRUE.
        ELSE
          CALL JEVEUO(MESUIV(1:19)//'.RELR','L',JMEC)
          IF ( ZK24(JMEC)(7:8) .EQ. '00' ) THEN
            BIDON = .TRUE.
          ENDIF  
        ENDIF
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF 
      IF (BIDON) THEN
        GOTO 9999
      ENDIF       
C
C --- ACCES AUX FONCTIONS MULTIPLICATRICES
C
      CALL JEEXIN(FOMULT,IRET)
      IF ( IRET .EQ. 0 ) THEN
        FCT    = .FALSE.
      ELSE
        FCT    = .TRUE.
        CALL JELIRA(FOMULT,'LONMAX',NCHAR,K8BID)
        IF ( NCHAR .EQ. 0 ) THEN
          CALL ASSERT(.FALSE.)
        ENDIF
        CALL JEVEUO(FOMULT,'L',JFONCT)
      ENDIF
C
C --- CREATION SD COEF
C
      CALL JEDETR(LICOEF)
      CALL WKVECT(LICOEF,'V V R',NBCHME,JLICOE)
      DO 1 ICHAR = 1,NBCHME
        IF ( FCT ) THEN
C
C ------- ON RECUPERE LE NUMERO DE LA CHARGE ICHA STOCKEE DANS LE NOM
C ------- DU VECTEUR ASSEMBLE
C
          CALL LXLIIS(ZK24(JMEC+ICHAR-1)(7:8),ICHA,IER)
          IF ( ICHA .GT. 0 ) THEN
            CALL FOINTE('F ',ZK24(JFONCT+ICHA-1)(1:8),1,'INST',INSTAN,
     &                  VALRES,IER)
          ELSE
            CALL ASSERT(.FALSE.)
          ENDIF
        ELSE
          VALRES = 1.D0
        ENDIF
        ZR(JLICOE+ICHAR-1)  = VALRES
 1    CONTINUE 
C 
9999  CONTINUE 
C
      CALL JEDEMA()        
C
      END

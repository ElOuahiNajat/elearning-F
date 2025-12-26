// ChapterRepository.java
package com.example.elearning.repositories;

import com.example.elearning.entities.Chapter;
import com.example.elearning.entities.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChapterRepository extends JpaRepository<Chapter, Long> {

    // Méthode existante
    List<Chapter> findByCourseOrderByOrderNumberAsc(Course course);

    // AVEC pagination
    Page<Chapter> findByCourseId(Long courseId, Pageable pageable);

    // SANS pagination (AJOUTEZ CETTE MÉTHODE)
    List<Chapter> findByCourseId(Long courseId);

    // OU avec un nom différent
    List<Chapter> findAllByCourseId(Long courseId);

    // Pour vérifier si un orderNumber existe déjà
    @Query("SELECT CASE WHEN COUNT(c) > 0 THEN true ELSE false END " +
            "FROM Chapter c WHERE c.course.id = :courseId AND c.orderNumber = :orderNumber")
    boolean existsByCourseIdAndOrderNumber(@Param("courseId") Long courseId,
                                           @Param("orderNumber") Integer orderNumber);

    // Pour trouver le numéro d'ordre maximum
    @Query("SELECT MAX(c.orderNumber) FROM Chapter c WHERE c.course.id = :courseId")
    Integer findMaxOrderNumberByCourseId(@Param("courseId") Long courseId);

    // Pour compter
    Long countByCourseId(Long courseId);

}
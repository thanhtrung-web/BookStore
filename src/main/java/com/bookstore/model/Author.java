package com.bookstore.model;

public class Author {

    private Long id;
    private String name;
    private String bio;
    private boolean isDeleted;

    // Constructor không tham số
    public Author() {
    }

    // Constructor dùng khi tạo tác giả mới
    public Author(String name, String bio) {
        this.name = name;
        this.bio = bio;
        this.isDeleted = false;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public boolean isDeleted() {
        return isDeleted;
    }

    public void setDeleted(boolean deleted) {
        isDeleted = deleted;
    }
}

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

User.create([
    {
        first_name: 'Support',
        last_name: 'Administrator',
        email: 'suppadmin@sharklasers.com',
        username: 'suppadmin',
        password: 'n@b!dEMo818#)',
        is_admin: true
    }
])

Project.create([
    { 
        name: 'Nabi Project',
        description: 'React + Ruby on Rails Bug Tracking Application',
        code: 'nabi-project'
    }
])

ProjectMembership.create([
    { 
        project_id: Project.first.id,
        user_id: User.first.id
    }
])